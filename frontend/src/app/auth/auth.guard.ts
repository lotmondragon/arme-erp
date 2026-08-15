import { inject } from '@angular/core';
import { Router, CanActivateFn } from '@angular/router';

export const authGuard: CanActivateFn = () => {
  const router = inject(Router);
  
  // Check if access token exists in localStorage
  const token = localStorage.getItem('access_token');
  
  if (!token) {
    console.log('AuthGuard: No token found, redirecting to login');
    router.navigate(['/login']);
    return false;
  }
  
  // Validate token format and expiration
  try {
    const tokenParts = token.split('.');
    if (tokenParts.length !== 3) {
      console.log('AuthGuard: Invalid token format, redirecting to login');
      localStorage.removeItem('access_token');
      localStorage.removeItem('refresh_token');
      router.navigate(['/login']);
      return false;
    }
    
    // Decode JWT payload
    const payload = JSON.parse(atob(tokenParts[1]));
    const expirationTime = payload.exp * 1000; // Convert to milliseconds
    const currentTime = Date.now();
    
    if (currentTime >= expirationTime) {
      console.log('AuthGuard: Token expired, redirecting to login');
      localStorage.removeItem('access_token');
      localStorage.removeItem('refresh_token');
      router.navigate(['/login']);
      return false;
    }
    
    console.log('AuthGuard: Valid token found, allowing access');
    return true;
  } catch (error) {
    console.error('AuthGuard: Error validating token:', error);
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
    router.navigate(['/login']);
    return false;
  }
};
