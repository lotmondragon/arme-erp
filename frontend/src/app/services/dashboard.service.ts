import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface DashboardSummary {
  totalProjects: number;
  activeProjects: number;
  planningProjects: number;
  completedProjects: number;
  totalClients: number;
  newClientsThisMonth: number;
  totalRevenue: number;
  totalExpenses: number;
  netProfit: number;
  profitMargin: number;
  pendingReceivables: number;
  pendingPayables: number;
  recentProjects: ProjectSummary[];
  projectFinancials: FinancialSummary[];
}

export interface ProjectSummary {
  id: string;
  projectCode: string;
  name: string;
  clientName: string;
  status: string;
  progressPercentage: number;
  healthStatus: string;
  contractAmount: number;
}

export interface FinancialSummary {
  projectId: string;
  projectCode: string;
  projectName: string;
  contractAmount: number;
  totalIncome: number;
  totalExpenses: number;
  netProfit: number;
  profitMargin: number;
}

@Injectable({
  providedIn: 'root'
})
export class DashboardService {
  private http = inject(HttpClient);
  private apiUrl = `${environment.apiUrl}/dashboard`;

  getSummary(): Observable<DashboardSummary> {
    return this.http.get<DashboardSummary>(`${this.apiUrl}/summary`);
  }
}
