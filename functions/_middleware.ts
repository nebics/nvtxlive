// HTTP Basic Auth Middleware - protects all routes including /api/*
const CREDENTIALS = {
  username: 'dev_env1',
  password: 'z7kws3mfl5e2y'
};

export const onRequest: PagesFunction = async (context) => {
  const { request } = context;
  const authorization = request.headers.get('Authorization');

  if (!authorization) {
    return new Response('Authentication required', {
      status: 401,
      headers: {
        'WWW-Authenticate': 'Basic realm="Protected Area"'
      }
    });
  }

  const [scheme, encoded] = authorization.split(' ');

  if (scheme !== 'Basic') {
    return new Response('Invalid authentication scheme', { status: 401 });
  }

  try {
    const decoded = atob(encoded);
    const [username, password] = decoded.split(':');

    if (username !== CREDENTIALS.username || password !== CREDENTIALS.password) {
      return new Response('Invalid credentials', {
        status: 401,
        headers: {
          'WWW-Authenticate': 'Basic realm="Protected Area"'
        }
      });
    }
  } catch (e) {
    return new Response('Invalid authorization header', { status: 401 });
  }

  // Auth passed - continue to next handler (Functions or static assets)
  return context.next();
};
