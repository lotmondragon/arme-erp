import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface Project {
  id: string;
  projectCode: string;
  name: string;
  description?: string;
  location: string;
  city?: string;
  state?: string;
  status: string;
  progressPercentage: number;
  healthStatus: string;
  plannedStartDate?: string;
  plannedEndDate?: string;
  actualStartDate?: string;
  actualEndDate?: string;
  totalArea?: number;
  contractAmount: number;
  currentBudget: number;
  totalExpenses: number;
  totalIncome: number;
  priority: string;
  clientId: string;
  clientName: string;
  netProfit: number;
  profitMargin: number;
  createdAt: string;
}

export interface CreateProject {
  name: string;
  description?: string;
  location: string;
  city?: string;
  state?: string;
  clientId: string;
  plannedStartDate?: string;
  plannedEndDate?: string;
  totalArea?: number;
  coveredArea?: number;
  contractAmount: number;
  priority?: string;
  notes?: string;
}

export interface UpdateProject {
  id: string;
  name: string;
  description?: string;
  location: string;
  city?: string;
  state?: string;
  status: string;
  progressPercentage: number;
  healthStatus: string;
  plannedStartDate?: string;
  plannedEndDate?: string;
  actualStartDate?: string;
  actualEndDate?: string;
  totalArea?: number;
  coveredArea?: number;
  contractAmount: number;
  priority: string;
  notes?: string;
}

@Injectable({
  providedIn: 'root'
})
export class ProjectService {
  private http = inject(HttpClient);
  private apiUrl = `${environment.apiUrl}/projects`;

  getAll(): Observable<Project[]> {
    return this.http.get<Project[]>(this.apiUrl);
  }

  getById(id: string): Observable<Project> {
    return this.http.get<Project>(`${this.apiUrl}/${id}`);
  }

  create(project: CreateProject): Observable<Project> {
    return this.http.post<Project>(this.apiUrl, project);
  }

  update(id: string, project: UpdateProject): Observable<Project> {
    return this.http.put<Project>(`${this.apiUrl}/${id}`, project);
  }

  delete(id: string): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }
}
