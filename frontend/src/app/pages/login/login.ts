import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { OidcSecurityService } from 'angular-auth-oidc-client';
import { environment } from '../../../environments/environment';

@Component({
  selector: 'app-login',
  imports: [CommonModule, FormsModule],
  templateUrl: './login.html',
  styleUrl: './login.scss'
})
export class Login implements OnInit {
  private http = inject(HttpClient);
  private router = inject(Router);
  private oidcSecurityService = inject(OidcSecurityService);

  username = 'admin@arme.com';
  password = 'Admin123!';
  errorMessage = '';
  loading = false;

  ngOnInit() {
    // Verificar si hay un token válido
    const token = localStorage.getItem('access_token');
    if (token) {
      try {
        // Validar formato y expiración del token
        const tokenParts = token.split('.');
        if (tokenParts.length === 3) {
          const payload = JSON.parse(atob(tokenParts[1]));
          const expirationTime = payload.exp * 1000;
          const currentTime = Date.now();
          
          if (currentTime < expirationTime) {
            // Token válido, redirigir al dashboard
            console.log('Valid token found, redirecting to dashboard');
            this.router.navigate(['/dashboard']);
            return;
          }
        }
      } catch (error) {
        console.error('Error validating token:', error);
      }
      
      // Si llegamos aquí, el token es inválido o expiró
      console.log('Invalid or expired token, clearing storage');
      localStorage.removeItem('access_token');
      localStorage.removeItem('refresh_token');
    }
  }

  async login() {
    this.loading = true;
    this.errorMessage = '';

    try {
      const tokenEndpoint = `${environment.authUrl}/connect/token`;
      const body = new URLSearchParams({
        grant_type: 'password',
        username: this.username,
        password: this.password,
        client_id: 'web-client',
        client_secret: environment.clientSecret,
        scope: 'openid profile email offline_access api'
      });

      console.log('Attempting login to:', tokenEndpoint);
      
      const response: any = await this.http.post(tokenEndpoint, body.toString(), {
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
      }).toPromise();

      console.log('Login response:', response);

      if (response && response.access_token) {
        console.log('Token received, storing and navigating...');
        // Store tokens manually (for password flow)
        localStorage.setItem('access_token', response.access_token);
        if (response.refresh_token) {
          localStorage.setItem('refresh_token', response.refresh_token);
        }
        await this.router.navigate(['/dashboard']);
        console.log('Navigation complete');
      } else {
        console.error('No access token in response:', response);
        this.errorMessage = 'No se recibió token de acceso';
      }
    } catch (error: any) {
      console.error('Login error:', error);
      this.errorMessage = error.error?.error_description || error.message || 'Login failed. Please check your credentials.';
    } finally {
      this.loading = false;
    }
  }
}
