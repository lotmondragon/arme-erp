import { HttpInterceptorFn, HttpErrorResponse } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, throwError } from 'rxjs';
import { NotificationService } from '../services/notification.service';

export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  const router = inject(Router);
  const notificationService = inject(NotificationService);

  return next(req).pipe(
    catchError((error: HttpErrorResponse) => {
      let errorMessage = 'Ha ocurrido un error inesperado';

      if (error.error instanceof ErrorEvent) {
        // Error del cliente (red, etc.)
        errorMessage = `Error: ${error.error.message}`;
      } else {
        // Error del servidor
        switch (error.status) {
          case 0:
            errorMessage = 'No se puede conectar con el servidor. Verifica tu conexión.';
            break;
          case 400:
            errorMessage = error.error?.error_description || 'Solicitud inválida';
            break;
          case 401:
            errorMessage = 'Sesión expirada. Por favor, inicia sesión nuevamente.';
            // El auth.interceptor ya maneja la redirección
            break;
          case 403:
            errorMessage = 'No tienes permisos para realizar esta acción';
            break;
          case 404:
            errorMessage = 'Recurso no encontrado';
            break;
          case 500:
            errorMessage = 'Error interno del servidor. Intenta nuevamente más tarde.';
            break;
          case 503:
            errorMessage = 'Servicio no disponible. Intenta nuevamente más tarde.';
            break;
          default:
            errorMessage = `Error ${error.status}: ${error.message}`;
        }
      }

      // Mostrar notificación de error (excepto 401 que ya se maneja)
      if (error.status !== 401) {
        notificationService.error(errorMessage);
      }

      console.error('HTTP Error:', {
        status: error.status,
        message: errorMessage,
        url: req.url,
        error: error.error
      });

      return throwError(() => error);
    })
  );
};
