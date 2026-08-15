import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { DashboardService, DashboardSummary } from '../../services/dashboard.service';

@Component({
  selector: 'app-dashboard',
  imports: [CommonModule],
  templateUrl: './dashboard.html',
  styleUrl: './dashboard.scss'
})
export class Dashboard implements OnInit {
  private dashboardService = inject(DashboardService);
  private router = inject(Router);

  summary: DashboardSummary | null = null;
  loading = true;
  error = '';

  ngOnInit() {
    this.loadDashboard();
  }

  loadDashboard() {
    this.loading = true;
    console.log('Loading dashboard...');
    this.dashboardService.getSummary().subscribe({
      next: (data) => {
        console.log('Dashboard data received:', data);
        this.summary = data;
        this.loading = false;
      },
      error: (err) => {
        console.error('Dashboard error:', err);
        console.error('Error status:', err.status);
        console.error('Error message:', err.message);
        this.error = 'Error al cargar el dashboard: ' + (err.message || 'Error desconocido');
        this.loading = false;
      },
      complete: () => {
        console.log('Dashboard loading complete');
      }
    });
  }

  formatCurrency(value: number): string {
    return new Intl.NumberFormat('es-MX', {
      style: 'currency',
      currency: 'MXN'
    }).format(value);
  }

  formatPercent(value: number): string {
    return `${value.toFixed(2)}%`;
  }

  getStatusClass(status: string): string {
    const statusMap: { [key: string]: string } = {
      'Planning': 'status-planning',
      'InProgress': 'status-progress',
      'Completed': 'status-completed',
      'OnHold': 'status-hold'
    };
    return statusMap[status] || 'status-default';
  }

  getStatusBadgeClass(status: string): string {
    const statusMap: { [key: string]: string } = {
      'Planning': 'bg-yellow-100 text-yellow-800',
      'InProgress': 'bg-blue-100 text-blue-800',
      'Completed': 'bg-green-100 text-green-800',
      'OnHold': 'bg-gray-100 text-gray-800'
    };
    return statusMap[status] || 'bg-gray-100 text-gray-800';
  }

  getStatusText(status: string): string {
    const statusMap: { [key: string]: string } = {
      'Planning': 'Planificación',
      'InProgress': 'En Progreso',
      'Completed': 'Completado',
      'OnHold': 'En Espera'
    };
    return statusMap[status] || status;
  }

  getHealthClass(health: string): string {
    const healthMap: { [key: string]: string } = {
      'on_track': 'health-good',
      'at_risk': 'health-warning',
      'delayed': 'health-danger'
    };
    return healthMap[health] || 'health-default';
  }

  getHealthBadgeClass(health: string): string {
    const healthMap: { [key: string]: string } = {
      'on_track': 'bg-green-100 text-green-800',
      'at_risk': 'bg-yellow-100 text-yellow-800',
      'delayed': 'bg-red-100 text-red-800'
    };
    return healthMap[health] || 'bg-gray-100 text-gray-800';
  }

  getHealthText(health: string): string {
    const healthMap: { [key: string]: string } = {
      'on_track': 'En Tiempo',
      'at_risk': 'En Riesgo',
      'delayed': 'Retrasado'
    };
    return healthMap[health] || health;
  }

  logout() {
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
    this.router.navigate(['/login']);
  }
}
