import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { ProjectService, Project } from '../../services/project.service';

@Component({
  selector: 'app-projects-list',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="page-container">
      <div class="page-header">
        <div>
          <h1>Proyectos</h1>
          <p class="subtitle">Gestión de obras y construcciones</p>
        </div>
        <button (click)="navigateToCreate()" class="btn btn-primary">
          <span class="icon">+</span> Nuevo Proyecto
        </button>
      </div>

      <div class="filters-bar">
        <div class="search-box">
          <input type="text" placeholder="Buscar proyectos..." [(ngModel)]="searchTerm" (input)="filterProjects()">
        </div>
        <div class="filter-buttons">
          <button [class.active]="statusFilter === 'all'" (click)="filterByStatus('all')">Todos</button>
          <button [class.active]="statusFilter === 'Planning'" (click)="filterByStatus('Planning')">Planeación</button>
          <button [class.active]="statusFilter === 'InProgress'" (click)="filterByStatus('InProgress')">En Progreso</button>
          <button [class.active]="statusFilter === 'Completed'" (click)="filterByStatus('Completed')">Completados</button>
        </div>
      </div>

      <div *ngIf="loading" class="loading-state">
        <div class="spinner"></div>
        <p>Cargando proyectos...</p>
      </div>

      <div *ngIf="error" class="error-state">
        <p>{{ error }}</p>
        <button (click)="loadProjects()" class="btn btn-secondary">Reintentar</button>
      </div>

      <div *ngIf="!loading && filteredProjects.length === 0" class="empty-state">
        <div class="empty-icon">📋</div>
        <h3>No hay proyectos</h3>
        <p>Comienza creando tu primer proyecto</p>
        <button (click)="navigateToCreate()" class="btn btn-primary">Crear Proyecto</button>
      </div>

      <div *ngIf="!loading && filteredProjects.length > 0" class="projects-grid">
        <div *ngFor="let project of filteredProjects" class="project-card" (click)="viewProject(project.id)">
          <div class="card-header">
            <div class="project-info">
              <h3>{{ project.name }}</h3>
              <span class="project-code">{{ project.projectCode }}</span>
            </div>
            <span [class]="'badge badge-' + getStatusClass(project.status)">
              {{ getStatusLabel(project.status) }}
            </span>
          </div>

          <div class="card-body">
            <div class="info-row">
              <span class="label">Cliente:</span>
              <span class="value">{{ project.clientName }}</span>
            </div>
            <div class="info-row">
              <span class="label">Ubicación:</span>
              <span class="value">{{ project.location }}</span>
            </div>
            <div class="info-row">
              <span class="label">Monto:</span>
              <span class="value amount">{{ formatCurrency(project.contractAmount) }}</span>
            </div>
          </div>

          <div class="card-progress">
            <div class="progress-header">
              <span>Avance</span>
              <span class="percentage">{{ project.progressPercentage }}%</span>
            </div>
            <div class="progress-bar">
              <div class="progress-fill" [style.width.%]="project.progressPercentage"></div>
            </div>
          </div>

          <div class="card-footer">
            <span [class]="'health-badge health-' + project.healthStatus">
              {{ getHealthLabel(project.healthStatus) }}
            </span>
            <div class="card-actions">
              <button (click)="viewProject(project.id); $event.stopPropagation()" class="btn-icon" title="Ver detalles">
                👁️
              </button>
              <button (click)="editProject(project.id); $event.stopPropagation()" class="btn-icon" title="Editar">
                ✏️
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .page-container {
      padding: 2rem;
      max-width: 1400px;
      margin: 0 auto;
    }

    .page-header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      margin-bottom: 2rem;
    }

    .page-header h1 {
      margin: 0;
      font-size: 2rem;
      color: #1a202c;
    }

    .subtitle {
      color: #718096;
      margin-top: 0.5rem;
    }

    .filters-bar {
      display: flex;
      gap: 1rem;
      margin-bottom: 2rem;
      flex-wrap: wrap;
    }

    .search-box {
      flex: 1;
      min-width: 300px;
    }

    .search-box input {
      width: 100%;
      padding: 0.75rem 1rem;
      border: 1px solid #e2e8f0;
      border-radius: 8px;
      font-size: 1rem;
    }

    .filter-buttons {
      display: flex;
      gap: 0.5rem;
    }

    .filter-buttons button {
      padding: 0.75rem 1.5rem;
      border: 1px solid #e2e8f0;
      background: white;
      border-radius: 8px;
      cursor: pointer;
      transition: all 0.2s;
    }

    .filter-buttons button.active {
      background: #4299e1;
      color: white;
      border-color: #4299e1;
    }

    .projects-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
      gap: 1.5rem;
    }

    .project-card {
      background: white;
      border-radius: 12px;
      padding: 1.5rem;
      box-shadow: 0 1px 3px rgba(0,0,0,0.1);
      cursor: pointer;
      transition: all 0.3s;
    }

    .project-card:hover {
      box-shadow: 0 4px 12px rgba(0,0,0,0.15);
      transform: translateY(-2px);
    }

    .card-header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      margin-bottom: 1rem;
    }

    .project-info h3 {
      margin: 0;
      font-size: 1.25rem;
      color: #1a202c;
    }

    .project-code {
      display: block;
      font-size: 0.875rem;
      color: #718096;
      margin-top: 0.25rem;
    }

    .badge {
      padding: 0.25rem 0.75rem;
      border-radius: 12px;
      font-size: 0.75rem;
      font-weight: 600;
    }

    .badge-planning { background: #bee3f8; color: #2c5282; }
    .badge-inprogress { background: #c6f6d5; color: #22543d; }
    .badge-completed { background: #e9d8fd; color: #44337a; }
    .badge-onhold { background: #fed7d7; color: #742a2a; }

    .card-body {
      margin-bottom: 1rem;
    }

    .info-row {
      display: flex;
      justify-content: space-between;
      padding: 0.5rem 0;
      border-bottom: 1px solid #f7fafc;
    }

    .info-row .label {
      color: #718096;
      font-size: 0.875rem;
    }

    .info-row .value {
      color: #1a202c;
      font-weight: 500;
    }

    .value.amount {
      color: #38a169;
      font-weight: 600;
    }

    .card-progress {
      margin-bottom: 1rem;
    }

    .progress-header {
      display: flex;
      justify-content: space-between;
      margin-bottom: 0.5rem;
      font-size: 0.875rem;
    }

    .percentage {
      font-weight: 600;
      color: #4299e1;
    }

    .progress-bar {
      height: 8px;
      background: #edf2f7;
      border-radius: 4px;
      overflow: hidden;
    }

    .progress-fill {
      height: 100%;
      background: linear-gradient(90deg, #4299e1, #3182ce);
      transition: width 0.3s;
    }

    .card-footer {
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .health-badge {
      padding: 0.25rem 0.75rem;
      border-radius: 12px;
      font-size: 0.75rem;
      font-weight: 600;
    }

    .health-on_track { background: #c6f6d5; color: #22543d; }
    .health-at_risk { background: #feebc8; color: #7c2d12; }
    .health-delayed { background: #fed7d7; color: #742a2a; }

    .card-actions {
      display: flex;
      gap: 0.5rem;
    }

    .btn-icon {
      background: none;
      border: none;
      font-size: 1.25rem;
      cursor: pointer;
      padding: 0.25rem;
      opacity: 0.7;
      transition: opacity 0.2s;
    }

    .btn-icon:hover {
      opacity: 1;
    }

    .btn {
      padding: 0.75rem 1.5rem;
      border: none;
      border-radius: 8px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s;
      display: inline-flex;
      align-items: center;
      gap: 0.5rem;
    }

    .btn-primary {
      background: #4299e1;
      color: white;
    }

    .btn-primary:hover {
      background: #3182ce;
    }

    .btn-secondary {
      background: #edf2f7;
      color: #1a202c;
    }

    .loading-state, .error-state, .empty-state {
      text-align: center;
      padding: 4rem 2rem;
    }

    .spinner {
      width: 50px;
      height: 50px;
      border: 4px solid #edf2f7;
      border-top-color: #4299e1;
      border-radius: 50%;
      animation: spin 1s linear infinite;
      margin: 0 auto 1rem;
    }

    @keyframes spin {
      to { transform: rotate(360deg); }
    }

    .empty-icon {
      font-size: 4rem;
      margin-bottom: 1rem;
    }
  `]
})
export class ProjectsListComponent implements OnInit {
  private projectService = inject(ProjectService);
  private router = inject(Router);
  
  projects: Project[] = [];
  filteredProjects: Project[] = [];
  loading = true;
  error = '';
  searchTerm = '';
  statusFilter = 'all';

  ngOnInit() {
    this.loadProjects();
  }

  loadProjects() {
    this.loading = true;
    this.error = '';
    
    this.projectService.getAll().subscribe({
      next: (data) => {
        this.projects = data;
        this.filteredProjects = data;
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Error al cargar los proyectos';
        this.loading = false;
        console.error('Error:', err);
      }
    });
  }

  filterProjects() {
    let filtered = this.projects;

    if (this.statusFilter !== 'all') {
      filtered = filtered.filter(p => p.status === this.statusFilter);
    }

    if (this.searchTerm) {
      const term = this.searchTerm.toLowerCase();
      filtered = filtered.filter(p => 
        p.name.toLowerCase().includes(term) ||
        p.projectCode.toLowerCase().includes(term) ||
        p.clientName.toLowerCase().includes(term)
      );
    }

    this.filteredProjects = filtered;
  }

  filterByStatus(status: string) {
    this.statusFilter = status;
    this.filterProjects();
  }

  navigateToCreate() {
    this.router.navigate(['/projects/new']);
  }

  viewProject(id: string) {
    this.router.navigate(['/projects', id]);
  }

  editProject(id: string) {
    this.router.navigate(['/projects', id, 'edit']);
  }

  formatCurrency(value: number): string {
    return new Intl.NumberFormat('es-MX', {
      style: 'currency',
      currency: 'MXN'
    }).format(value);
  }

  getStatusClass(status: string): string {
    const map: any = {
      'Planning': 'planning',
      'InProgress': 'inprogress',
      'Completed': 'completed',
      'OnHold': 'onhold'
    };
    return map[status] || 'planning';
  }

  getStatusLabel(status: string): string {
    const map: any = {
      'Planning': 'Planeación',
      'InProgress': 'En Progreso',
      'Completed': 'Completado',
      'OnHold': 'En Pausa'
    };
    return map[status] || status;
  }

  getHealthLabel(health: string): string {
    const map: any = {
      'on_track': 'En Tiempo',
      'at_risk': 'En Riesgo',
      'delayed': 'Retrasado'
    };
    return map[health] || health;
  }
}
