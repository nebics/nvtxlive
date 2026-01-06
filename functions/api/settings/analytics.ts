interface Env {
    DB: D1Database;
}

export const onRequestGet: PagesFunction<Env> = async (context) => {
    const { env } = context;

    // Public endpoint, maybe cache this heavily
    const result = await env.DB.prepare("SELECT value FROM settings WHERE key = 'ga_snippet'").first();

    return new Response(JSON.stringify({ snippet: result?.value || '' }), {
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*', // Allow frontend to fetch
            'Cache-Control': 'public, max-age=300' // Cache for 5 mins
        }
    });
};
