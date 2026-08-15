import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, throwError } from 'rxjs';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const router = inject(Router);
  
  // Get token from localStorage
  const token = localStorage.getItem('access_token');
  
  // Add Authorization header if token exists and request is to API
  if (token && req.url.includes('/api')) {
    const clonedRequest = req.clone({
      setHeaders: {
        Authorization: `Bearer ${token}`
      }
    });
    
    return next(clonedRequest).pipe(
      catchError((error) => {
        // If 401 Unauthorized, clear tokens and redirect to login
        if (error.status === 401) {
          console.log('API returned 401, clearing tokens and redirecting to login');
          localStorage.removeItem('access_token');
          localStorage.removeItem('refresh_token');
          router.navigate(['/login']);
        }
        return throwError(() => error);
      })
    );
  }
  
  return next(req);
};
