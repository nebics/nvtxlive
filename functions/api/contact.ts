// POST /api/contact - Handle contact form submissions

interface Env {
  DB: D1Database;
}

interface ContactFormData {
  first_name: string;
  last_name: string;
  email: string;
  phone?: string;
  company?: string;
  inquiry_type: string;
  message: string;
  page_url?: string;
  submitted_at_local?: string;
  utm?: {
    source?: string;
    medium?: string;
    campaign?: string;
  };
}

export const onRequestPost: PagesFunction<Env> = async (context) => {
  const { request, env } = context;

  // CORS headers
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Content-Type': 'application/json',
  };

  try {
    let data: ContactFormData;
    try {
      data = await request.json();
    } catch (parseError: any) {
      console.error('JSON parse error:', parseError?.message);
      return new Response(
        JSON.stringify({ error: 'Invalid JSON in request body', details: parseError?.message }),
        { status: 400, headers: corsHeaders }
      );
    }

    // Validation - required fields
    if (!data.first_name || !data.last_name || !data.email || !data.inquiry_type || !data.message) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields', fields: ['first_name', 'last_name', 'email', 'inquiry_type', 'message'] }),
        { status: 400, headers: corsHeaders }
      );
    }

    // Email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(data.email)) {
      return new Response(
        JSON.stringify({ error: 'Invalid email address' }),
        { status: 400, headers: corsHeaders }
      );
    }

    // Build metadata object with Cloudflare geo data
    const cf = request.cf;
    const metadata = {
      ip: request.headers.get('CF-Connecting-IP') || request.headers.get('X-Forwarded-For'),
      user_agent: request.headers.get('User-Agent'),
      referrer: request.headers.get('Referer'),
      page_url: data.page_url || null,
      location: {
        country: cf?.country || null,
        region: cf?.region || null,
        city: cf?.city || null,
        timezone: cf?.timezone || null,
        postal_code: cf?.postalCode || null,
        latitude: cf?.latitude || null,
        longitude: cf?.longitude || null,
      },
      connection: {
        colo: cf?.colo || null,
        http_protocol: cf?.httpProtocol || null,
        tls_version: cf?.tlsVersion || null,
        asn: cf?.asn || null,
        as_organization: cf?.asOrganization || null,
      },
      utm: data.utm || null,
      submitted_at_local: data.submitted_at_local || null,
    };

    // Insert into D1
    const result = await env.DB.prepare(`
      INSERT INTO contact_messages (first_name, last_name, email, phone, company, inquiry_type, message, metadata)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `).bind(
      data.first_name.trim(),
      data.last_name.trim(),
      data.email.trim().toLowerCase(),
      data.phone?.trim() || null,
      data.company?.trim() || null,
      data.inquiry_type,
      data.message.trim(),
      JSON.stringify(metadata)
    ).run();

    return new Response(
      JSON.stringify({
        success: true,
        message: 'Thank you! Your message has been received.',
        id: result.meta.last_row_id
      }),
      { status: 200, headers: corsHeaders }
    );

  } catch (error: any) {
    console.error('Contact form error:', error?.message || error);
    return new Response(
      JSON.stringify({ error: 'Server error. Please try again later.', details: error?.message }),
      { status: 500, headers: corsHeaders }
    );
  }
};

// Handle CORS preflight
export const onRequestOptions: PagesFunction = async () => {
  return new Response(null, {
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    },
  });
};
