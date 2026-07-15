import { serve } from "https://deno.land/std@0.190.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: req.headers.get("Authorization")! } } }
    );

    const body = await req.json();

    const { data, error } = await supabase.rpc("create_provider_voucher", {
      p_provider_id: body.provider_id,
      p_code: body.code,
      p_discount_type: body.discount_type,
      p_discount_value: body.discount_value,
      p_max_discount_amount: body.max_discount_amount ?? null,
      p_min_order_value: body.min_order_value ?? 0,
      p_usage_limit: body.usage_limit ?? null,
      p_usage_limit_per_user: body.usage_limit_per_user ?? 1,
      p_applicable_service_ids: body.applicable_service_ids ?? null,
      p_start_date: body.start_date,
      p_end_date: body.end_date,
    });

    if (error) throw error;

    return new Response(JSON.stringify(data), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (err) {
    return new Response(JSON.stringify({ success: false, error: err.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 400,
    });
  }
});