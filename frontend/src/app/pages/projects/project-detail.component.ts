import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, ActivatedRoute, RouterLink } from '@angular/router';
import { ProjectService, Project } from '../../services/project.service';

@Component({
  selector: 'app-project-detail',
  standalone: true,
  imports: [CommonModule, RouterLink],
  template: `
    <div class="detail-container">
      <div *ngIf="loading" class="loading-state">
        <div class="spinner"></div>
        <p>Cargando proyecto...</p>
      </div>

      <div *ngIf="!loading && project" class="project-detail">
        <!-- Header -->
        <div class="detail-header">
          <div class="header-left">
            <button (click)="goBack()" class="btn-back">← Volver</button>
            <div class="header-info">
              <h1>{{ project.name }}</h1>
              <span class="project-code">{{ project.projectCode }}</span>
            </div>
          </div>
          <div class="header-actions">
            <button [routerLink]="['/projects', project.id, 'edit']" class="btn btn-secondary">
              ✏️ Editar
            </button>
            <span [class]="'badge badge-' + getStatusClass(project.status)">
              {{ getStatusLabel(project.status) }}
            </span>
          </div>
        </div>

        <!-- Stats Cards -->
        <div class="stats-grid">
          <div class="stat-card">
            <div class="stat-icon">💰</div>
            <div class="stat-info">
              <span class="stat-label">Monto Contratado</span>
              <span class="stat-value">{{ formatCurrency(project.contractAmount) }}</span>
            </div>
          </div>

          <div class="stat-card">
            <div class="stat-icon">📊</div>
            <div class="stat-info">
              <span class="stat-label">Avance</span>
              <span class="stat-value">{{ project.progressPercentage }}%</span>
            </div>
          </div>

          <div class="stat-card">
            <div class="stat-icon">💵</div>
            <div class="stat-info">
              <span class="stat-label">Ingresos</span>
              <span class="stat-value success">{{ formatCurrency(project.totalIncome) }}</span>
            </div>
          </div>

          <div class="stat-card">
            <div class="stat-icon">💸</div>
            <div class="stat-info">
              <span class="stat-label">Gastos</span>
              <span class="stat-value danger">{{ formatCurrency(project.totalExpenses) }}</span>
            </div>
          </div>

          <div class="stat-card">
            <div class="stat-icon">📈</div>
            <div class="stat-info">
              <span class="stat-label">Utilidad</span>
              <span [class]="'stat-value ' + (project.netProfit >= 0 ? 'success' : 'danger')">
                {{ formatCurrency(project.netProfit) }}
              </span>
            </div>
          </div>

          <div class="stat-card">
            <div class="stat-icon">🎯</div>
            <div class="stat-info">
              <span class="stat-label">Margen</span>
              <span [class]="'stat-value ' + (project.profitMargin >= 0 ? 'success' : 'danger')">
                {{ project.profitMargin.toFixed(2) }}%
              </span>
            </div>
          </div>
        </div>

        <!-- Main Content -->
        <div class="content-grid">
          <!-- Información General -->
          <div class="info-card">
            <h2>Información General</h2>
            <div class="info-list">
              <div class="info-item">
                <span class="label">Cliente:</span>
                <span class="value">{{ project.clientName }}</span>
              </div>
              <div class="info-item">
                <span class="label">Ubicación:</span>
                <span class="value">{{ project.location }}</span>
              </div>
              <div class="info-item" *ngIf="project.city">
                <span class="label">Ciudad:</span>
                <span class="value">{{ project.city }}, {{ project.state }}</span>
              </div>
              <div class="info-item" *ngIf="project.totalArea">
                <span class="label">Área Total:</span>
                <span class="value">{{ project.totalArea }} m²</span>
              </div>
              <div class="info-item">
                <span class="label">Prioridad:</span>
                <span [class]="'badge badge-' + project.priority">{{ getPriorityLabel(project.priority) }}</span>
              </div>
              <div class="info-item">
                <span class="label">Estado de Salud:</span>
                <span [class]="'health-badge health-' + project.healthStatus">
                  {{ getHealthLabel(project.healthStatus) }}
                </span>
              </div>
            </div>
          </div>

          <!-- Fechas -->
          <div class="info-card">
            <h2>Fechas del Proyecto</h2>
            <div class="info-list">
              <div class="info-item" *ngIf="project.plannedStartDate">
                <span class="label">Inicio Planeado:</span>
                <span class="value">{{ formatDate(project.plannedStartDate) }}</span>
              </div>
              <div class="info-item" *ngIf="project.plannedEndDate">
                <span class="label">Fin Planeado:</span>
                <span class="value">{{ formatDate(project.plannedEndDate) }}</span>
              </div>
              <div class="info-item" *ngIf="project.actualStartDate">
                <span class="label">Inicio Real:</span>
                <span class="value">{{ formatDate(project.actualStartDate) }}</span>
              </div>
              <div class="info-item" *ngIf="project.actualEndDate">
                <span class="label">Fin Real:</span>
                <span class="value">{{ formatDate(project.actualEndDate) }}</span>
              </div>
              <div class="info-item">
                <span class="label">Creado:</span>
                <span class="value">{{ formatDate(project.createdAt) }}</span>
              </div>
            </div>
          </div>

          <!-- Descripción -->
          <div class="info-card full-width" *ngIf="project.description">
            <h2>Descripción</h2>
            <p class="description">{{ project.description }}</p>
          </div>

          <!-- Progress Bar -->
          <div class="info-card full-width">
            <h2>Progreso del Proyecto</h2>
            <div class="progress-section">
              <div class="progress-bar-large">
                <div class="progress-fill" [style.width.%]="project.progressPercentage"></div>
              </div>
              <span class="progress-percentage">{{ project.progressPercentage }}%</span>
            </div>
          </div>
        </div>

        <!-- Tabs Section -->
        <div class="tabs-section">
          <div class="tabs">
            <button [class.active]="activeTab === 'stages'" (click)="activeTab = 'stages'">
              Etapas
            </button>
            <button [class.active]="activeTab === 'finances'" (click)="activeTab = 'finances'">
              Finanzas
            </button>
            <button [class.active]="activeTab === 'documents'" (click)="activeTab = 'documents'">
              Documentos
            </button>
          </div>

          <div class="tab-content">
            <div *ngIf="activeTab === 'stages'" class="stages-tab">
              <p class="empty-message">Las etapas del proyecto se mostrarán aquí</p>
            </div>

            <div *ngIf="activeTab === 'finances'" class="finances-tab">
              <div class="finance-summary">
                <div class="finance-item">
                  <span class="label">Presupuesto:</span>
                  <span class="value">{{ formatCurrency(project.currentBudget) }}</span>
                </div>
                <div class="finance-item">
                  <span class="label">Ingresos:</span>
                  <span class="value success">{{ formatCurrency(project.totalIncome) }}</span>
                </div>
                <div class="finance-item">
                  <span class="label">Gastos:</span>
                  <span class="value danger">{{ formatCurrency(project.totalExpenses) }}</span>
                </div>
                <div class="finance-item">
                  <span class="label">Balance:</span>
                  <span [class]="'value ' + (project.netProfit >= 0 ? 'success' : 'danger')">
                    {{ formatCurrency(project.netProfit) }}
                  </span>
                </div>
              </div>
            </div>

            <div *ngIf="activeTab === 'documents'" class="documents-tab">
              <p class="empty-message">Los documentos del proyecto se mostrarán aquí</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .detail-container {
      padding: 2rem;
      max-width: 1400px;
      margin: 0 auto;
    }

    .detail-header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      margin-bottom: 2rem;
    }

    .header-left {
      display: flex;
      align-items: center;
      gap: 1rem;
    }

    .btn-back {
      background: none;
      border: 1px solid #e2e8f0;
      padding: 0.5rem 1rem;
      border-radius: 8px;
      cursor: pointer;
      font-size: 1rem;
      transition: all 0.2s;
    }

    .btn-back:hover {
      background: #f7fafc;
    }

    .header-info h1 {
      margin: 0;
      font-size: 2rem;
      color: #1a202c;
    }

    .project-code {
      display: block;
      color: #718096;
      font-size: 0.875rem;
      margin-top: 0.25rem;
    }

    .header-actions {
      display: flex;
      gap: 1rem;
      align-items: center;
    }

    .stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 1rem;
      margin-bottom: 2rem;
    }

    .stat-card {
      background: white;
      padding: 1.5rem;
      border-radius: 12px;
      box-shadow: 0 1px 3px rgba(0,0,0,0.1);
      display: flex;
      gap: 1rem;
      align-items: center;
    }

    .stat-icon {
      font-size: 2rem;
    }

    .stat-info {
      display: flex;
      flex-direction: column;
    }

    .stat-label {
      font-size: 0.875rem;
      color: #718096;
    }

    .stat-value {
      font-size: 1.5rem;
      font-weight: 700;
      color: #1a202c;
    }

    .stat-value.success {
      color: #38a169;
    }

    .stat-value.danger {
      color: #e53e3e;
    }

    .content-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 1.5rem;
      margin-bottom: 2rem;
    }

    .info-card {
      background: white;
      padding: 1.5rem;
      border-radius: 12px;
      box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    }

    .info-card.full-width {
      grid-column: 1 / -1;
    }

    .info-card h2 {
      margin: 0 0 1rem 0;
      font-size: 1.25rem;
      color: #2d3748;
    }

    .info-list {
      display: flex;
      flex-direction: column;
      gap: 0.75rem;
    }

    .info-item {
      display: flex;
      justify-content: space-between;
      padding: 0.5rem 0;
      border-bottom: 1px solid #f7fafc;
    }

    .info-item .label {
      color: #718096;
      font-weight: 500;
    }

    .info-item .value {
      color: #1a202c;
      font-weight: 600;
    }

    .description {
      color: #4a5568;
      line-height: 1.6;
    }

    .progress-section {
      display: flex;
      align-items: center;
      gap: 1rem;
    }

    .progress-bar-large {
      flex: 1;
      height: 24px;
      background: #edf2f7;
      border-radius: 12px;
      overflow: hidden;
    }

    .progress-fill {
      height: 100%;
      background: linear-gradient(90deg, #4299e1, #3182ce);
      transition: width 0.3s;
    }

    .progress-percentage {
      font-size: 1.5rem;
      font-weight: 700;
      color: #4299e1;
      min-width: 60px;
      text-align: right;
    }

    .tabs-section {
      background: white;
      border-radius: 12px;
      box-shadow: 0 1px 3px rgba(0,0,0,0.1);
      overflow: hidden;
    }

    .tabs {
      display: flex;
      border-bottom: 1px solid #e2e8f0;
    }

    .tabs button {
      flex: 1;
      padding: 1rem;
      border: none;
      background: none;
      cursor: pointer;
      font-weight: 600;
      color: #718096;
      transition: all 0.2s;
    }

    .tabs button.active {
      color: #4299e1;
      border-bottom: 2px solid #4299e1;
    }

    .tab-content {
      padding: 2rem;
    }

    .empty-message {
      text-align: center;
      color: #718096;
      padding: 2rem;
    }

    .finance-summary {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 1rem;
    }

    .finance-item {
      display: flex;
      flex-direction: column;
      gap: 0.5rem;
      padding: 1rem;
      background: #f7fafc;
      border-radius: 8px;
    }

    .finance-item .label {
      font-size: 0.875rem;
      color: #718096;
    }

    .finance-item .value {
      font-size: 1.25rem;
      font-weight: 700;
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
    .badge-low { background: #e2e8f0; color: #4a5568; }
    .badge-normal { background: #bee3f8; color: #2c5282; }
    .badge-high { background: #feebc8; color: #7c2d12; }
    .badge-urgent { background: #fed7d7; color: #742a2a; }

    .health-badge {
      padding: 0.25rem 0.75rem;
      border-radius: 12px;
      font-size: 0.75rem;
      font-weight: 600;
    }

    .health-on_track { background: #c6f6d5; color: #22543d; }
    .health-at_risk { background: #feebc8; color: #7c2d12; }
    .health-delayed { background: #fed7d7; color: #742a2a; }

    .btn {
      padding: 0.75rem 1.5rem;
      border: none;
      border-radius: 8px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s;
    }

    .btn-secondary {
      background: #edf2f7;
      color: #1a202c;
    }

    .btn-secondary:hover {
      background: #e2e8f0;
    }

    .loading-state {
      text-align: center;
      padding: 4rem;
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

    @media (max-width: 768px) {
      .content-grid {
        grid-template-columns: 1fr;
      }

      .stats-grid {
        grid-template-columns: 1fr;
      }
    }
  `]
})
export class ProjectDetailComponent implements OnInit {
  private projectService = inject(ProjectService);
  private router = inject(Router);
  private route = inject(ActivatedRoute);

  project: Project | null = null;
  loading = true;
  activeTab = 'stages';

  ngOnInit() {
    const id = this.route.snapshot.params['id'];
    if (id) {
      this.loadProject(id);
    }
  }

  loadProject(id: string) {
    this.projectService.getById(id).subscribe({
      next: (data) => {
        this.project = data;
        this.loading = false;
      },
      error: (err) => {
        console.error('Error loading project:', err);
        this.loading = false;
        this.router.navigate(['/projects']);
      }
    });
  }

  goBack() {
    this.router.navigate(['/projects']);
  }

  formatCurrency(value: number): string {
    return new Intl.NumberFormat('es-MX', {
      style: 'currency',
      currency: 'MXN'
    }).format(value);
  }

  formatDate(date: string): string {
    return new Date(date).toLocaleDateString('es-MX', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  }

  getStatusClass(status: string): string {
    const map: any = {
      'Planning': 'planning',
      'InProgress': 'inprogress',
      'Completed': 'completed'
    };
    return map[status] || 'planning';
  }

  getStatusLabel(status: string): string {
    const map: any = {
      'Planning': 'Planeación',
      'InProgress': 'En Progreso',
      'Completed': 'Completado'
    };
    return map[status] || status;
  }

  getPriorityLabel(priority: string): string {
    const map: any = {
      'low': 'Baja',
      'normal': 'Normal',
      'high': 'Alta',
      'urgent': 'Urgente'
    };
    return map[priority] || priority;
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
