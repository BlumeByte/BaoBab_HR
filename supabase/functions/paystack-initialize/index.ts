import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.49.1';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const PLAN_PRICING: Record<string, number> = {
  Basic: 4900,
  Pro: 14900,
  Enterprise: 49900,
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization') ?? '' } } },
    );

    const { data: authData } = await supabase.auth.getUser();
    const authUser = authData.user;
    if (!authUser) return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401, headers: corsHeaders });

    const { plan } = await req.json();
    const selectedPlan = typeof plan === 'string' && PLAN_PRICING[plan] != null ? plan : 'Basic';

    const { data: userRow } = await supabase
      .from('users')
      .select('id, company_id, email')
      .eq('auth_user_id', authUser.id)
      .single();

    const amount = PLAN_PRICING[selectedPlan];
    const reference = `BBHR_${crypto.randomUUID().replaceAll('-', '').slice(0, 20)}`;

    const paystackResponse = await fetch('https://api.paystack.co/transaction/initialize', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${Deno.env.get('PAYSTACK_SECRET_KEY')}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email: userRow?.email ?? authUser.email,
        amount,
        reference,
        metadata: {
          company_id: userRow?.company_id,
          plan: selectedPlan,
        },
      }),
    });

    const payload = await paystackResponse.json();
    if (!payload?.status) {
      return new Response(JSON.stringify({ error: payload?.message ?? 'Paystack initialize failed' }), {
        status: 400,
        headers: corsHeaders,
      });
    }

    await supabase.from('paystack_payment_references').insert({
      company_id: userRow?.company_id,
      reference,
      access_code: payload.data.access_code,
      authorization_url: payload.data.authorization_url,
      status: 'pending',
      amount: amount / 100,
      currency: 'NGN',
    });

    return new Response(
      JSON.stringify({
        authorization_url: payload.data.authorization_url,
        access_code: payload.data.access_code,
        reference,
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (e) {
    return new Response(JSON.stringify({ error: e instanceof Error ? e.message : 'Unexpected error' }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
