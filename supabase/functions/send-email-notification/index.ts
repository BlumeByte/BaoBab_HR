const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });

  try {
    const { to, subject, message } = await req.json();
    if (!to || !subject || !message) {
      return new Response(JSON.stringify({ error: 'to, subject and message are required' }), { status: 400, headers: corsHeaders });
    }

    // Hook your provider here (Resend/SendGrid/Postmark).
    // This stub keeps API shape stable and logs payload for server-side observability.
    console.log('Email notification request', { to, subject });

    return new Response(JSON.stringify({ ok: true }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: e instanceof Error ? e.message : 'Unexpected error' }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
