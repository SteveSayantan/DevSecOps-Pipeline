// src/mocks/handlers.js
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.post('*/api/auth/email-password/signup', () => {
    return new HttpResponse(null, {
      status: 200,
    });
  }),
  http.post('*/api/auth/email-password/signin', () => {
    return HttpResponse.json({
      data: {
        user: {
          _id: 'test-user-id',
          role: 'user',
        },
      },
      message: 'Successfully signed in',
    });
  }),
];
