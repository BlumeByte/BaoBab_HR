import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.49.1';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const PLAN_DAYS: Record<string, number> = {
  Basic: 30,
  Pro: 30,
  Enterprise: 30,
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
    if (!authData.user) return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401, headers: corsHeaders });

    const { reference } = await req.json();
    if (reference == null || reference.toString().trim().isEmpty) {
      return new Response(JSON.stringify({ error: 'reference required' }), { status: 400, headers: corsHeaders });
    }

    const ref = reference.toString().trim();

    const verifyResponse = await fetch(`https://api.paystack.co/transaction/verify/${encodeURIComponent(ref)}`, {
      headers: { Authorization: `Bearer ${Deno.env.get('PAYSTACK_SECRET_KEY')}` },
    });
    const payload = await verifyResponse.json();

    if (!payload?.status || payload?.data?.status !== 'success') {
      return new Response(JSON.stringify({ verified: false, error: payload?.message ?? 'verification failed' }), {
        status: 400,
        headers: corsHeaders,
      });
    }

    const { data: refRow } = await supabase
      .from('paystack_payment_references')
      .select('id, company_id')
      .eq('reference', ref)
      .maybeSingle();

    const metadata = payload?.data?.metadata ?? {};
    const plan = (metadata.plan ?? 'Basic').toString();
    const companyId = metadata.company_id?.toString() ?? refRow?.company_id;
    const paidAt = new Date(payload.data.paid_at ?? Date.now());
    const endsAt = new Date(paidAt.getTime() + (PLAN_DAYS[plan] ?? 30) * 24 * 60 * 60 * 1000);

    const { data: subscription } = await supabase
      .from('subscriptions')
      .insert({
        company_id: companyId,
        plan_name: plan,
        status: 'active',
        starts_at: paidAt.toISOString(),
        ends_at: endsAt.toISOString(),
      })
      .select('id')
      .single();

    await supabase.from('payments').insert({
      company_id: companyId,
      subscription_id: subscription?.id,
      amount: (payload.data.amount ?? 0) / 100,
      currency: payload.data.currency ?? 'NGN',
      payment_provider: 'paystack',
      paystack_reference: ref,
      paystack_transaction_id: payload.data.id?.toString(),
      status: 'success',
      paid_at: paidAt.toISOString(),
      raw_response: payload,
    });

    await supabase
      .from('paystack_payment_references')
      .update({
        subscription_id: subscription?.id,
        status: 'success',
        verified_at: new Date().toISOString(),
      })
      .eq('reference', ref);

    await supabase.rpc('refresh_company_subscription_status', { p_company_id: companyId });

    return new Response(JSON.stringify({ verified: true, company_id: companyId, plan, status: 'active' }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: e instanceof Error ? e.message : 'Unexpected error' }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
