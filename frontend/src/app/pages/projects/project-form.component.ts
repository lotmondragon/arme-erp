import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';
import { ProjectService, CreateProject } from '../../services/project.service';
import { ClientService } from '../../services/client.service';

@Component({
  selector: 'app-project-form',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  template: `
    <div class="form-container">
      <div class="form-header">
        <h1>{{ isEditMode ? 'Editar Proyecto' : 'Nuevo Proyecto' }}</h1>
        <button (click)="goBack()" class="btn-close">✕</button>
      </div>

      <form [formGroup]="projectForm" (ngSubmit)="onSubmit()" class="project-form">
        <div class="form-grid">
          <!-- Información Básica -->
          <div class="form-section">
            <h3>Información Básica</h3>
            
            <div class="form-group">
              <label for="name">Nombre del Proyecto *</label>
              <input 
                id="name" 
                type="text" 
                formControlName="name" 
                placeholder="Ej: Nave Industrial Parque Norte"
                [class.error]="isFieldInvalid('name')">
              <span class="error-message" *ngIf="isFieldInvalid('name')">
                El nombre es requerido
              </span>
            </div>

            <div class="form-group">
              <label for="clientId">Cliente *</label>
              <select id="clientId" formControlName="clientId" [class.error]="isFieldInvalid('clientId')">
                <option value="">Seleccione un cliente</option>
                <option *ngFor="let client of clients" [value]="client.id">
                  {{ client.companyName }}
                </option>
              </select>
              <span class="error-message" *ngIf="isFieldInvalid('clientId')">
                Debe seleccionar un cliente
              </span>
            </div>

            <div class="form-group">
              <label for="description">Descripción</label>
              <textarea 
                id="description" 
                formControlName="description" 
                rows="4"
                placeholder="Descripción detallada del proyecto"></textarea>
            </div>
          </div>

          <!-- Ubicación -->
          <div class="form-section">
            <h3>Ubicación</h3>
            
            <div class="form-group">
              <label for="location">Ubicación *</label>
              <input 
                id="location" 
                type="text" 
                formControlName="location" 
                placeholder="Ej: Parque Industrial Norte"
                [class.error]="isFieldInvalid('location')">
              <span class="error-message" *ngIf="isFieldInvalid('location')">
                La ubicación es requerida
              </span>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label for="city">Ciudad</label>
                <input id="city" type="text" formControlName="city" placeholder="Monterrey">
              </div>

              <div class="form-group">
                <label for="state">Estado</label>
                <input id="state" type="text" formControlName="state" placeholder="Nuevo León">
              </div>
            </div>
          </div>

          <!-- Fechas -->
          <div class="form-section">
            <h3>Fechas del Proyecto</h3>
            
            <div class="form-row">
              <div class="form-group">
                <label for="plannedStartDate">Fecha Inicio Planeada</label>
                <input id="plannedStartDate" type="date" formControlName="plannedStartDate">
              </div>

              <div class="form-group">
                <label for="plannedEndDate">Fecha Fin Planeada</label>
                <input id="plannedEndDate" type="date" formControlName="plannedEndDate">
              </div>
            </div>
          </div>

          <!-- Detalles Técnicos -->
          <div class="form-section">
            <h3>Detalles Técnicos</h3>
            
            <div class="form-row">
              <div class="form-group">
                <label for="totalArea">Área Total (m²)</label>
                <input id="totalArea" type="number" formControlName="totalArea" placeholder="5000">
              </div>

              <div class="form-group">
                <label for="coveredArea">Área Cubierta (m²)</label>
                <input id="coveredArea" type="number" formControlName="coveredArea" placeholder="4500">
              </div>
            </div>
          </div>

          <!-- Información Financiera -->
          <div class="form-section">
            <h3>Información Financiera</h3>
            
            <div class="form-row">
              <div class="form-group">
                <label for="contractAmount">Monto del Contrato *</label>
                <div class="input-with-prefix">
                  <span class="prefix">$</span>
                  <input 
                    id="contractAmount" 
                    type="number" 
                    formControlName="contractAmount" 
                    placeholder="8500000"
                    [class.error]="isFieldInvalid('contractAmount')">
                </div>
                <span class="error-message" *ngIf="isFieldInvalid('contractAmount')">
                  El monto del contrato es requerido
                </span>
              </div>

              <div class="form-group">
                <label for="priority">Prioridad</label>
                <select id="priority" formControlName="priority">
                  <option value="low">Baja</option>
                  <option value="normal">Normal</option>
                  <option value="high">Alta</option>
                  <option value="urgent">Urgente</option>
                </select>
              </div>
            </div>
          </div>

          <!-- Notas -->
          <div class="form-section full-width">
            <h3>Notas Adicionales</h3>
            
            <div class="form-group">
              <label for="notes">Notas</label>
              <textarea 
                id="notes" 
                formControlName="notes" 
                rows="3"
                placeholder="Notas o comentarios adicionales sobre el proyecto"></textarea>
            </div>
          </div>
        </div>

        <!-- Botones de Acción -->
        <div class="form-actions">
          <button type="button" (click)="goBack()" class="btn btn-secondary">
            Cancelar
          </button>
          <button type="submit" class="btn btn-primary" [disabled]="projectForm.invalid || saving">
            {{ saving ? 'Guardando...' : (isEditMode ? 'Actualizar' : 'Crear Proyecto') }}
          </button>
        </div>

        <div *ngIf="errorMessage" class="alert alert-error">
          {{ errorMessage }}
        </div>
      </form>
    </div>
  `,
  styles: [`
    .form-container {
      max-width: 1200px;
      margin: 0 auto;
      padding: 2rem;
    }

    .form-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 2rem;
    }

    .form-header h1 {
      margin: 0;
      font-size: 2rem;
      color: #1a202c;
    }

    .btn-close {
      background: none;
      border: none;
      font-size: 1.5rem;
      cursor: pointer;
      color: #718096;
      padding: 0.5rem;
    }

    .project-form {
      background: white;
      border-radius: 12px;
      padding: 2rem;
      box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    }

    .form-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 2rem;
    }

    .form-section {
      display: flex;
      flex-direction: column;
      gap: 1rem;
    }

    .form-section.full-width {
      grid-column: 1 / -1;
    }

    .form-section h3 {
      margin: 0 0 1rem 0;
      font-size: 1.125rem;
      color: #2d3748;
      padding-bottom: 0.5rem;
      border-bottom: 2px solid #e2e8f0;
    }

    .form-group {
      display: flex;
      flex-direction: column;
      gap: 0.5rem;
    }

    .form-row {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 1rem;
    }

    label {
      font-weight: 600;
      color: #4a5568;
      font-size: 0.875rem;
    }

    input, select, textarea {
      padding: 0.75rem;
      border: 1px solid #e2e8f0;
      border-radius: 8px;
      font-size: 1rem;
      transition: all 0.2s;
    }

    input:focus, select:focus, textarea:focus {
      outline: none;
      border-color: #4299e1;
      box-shadow: 0 0 0 3px rgba(66, 153, 225, 0.1);
    }

    input.error, select.error {
      border-color: #fc8181;
    }

    .input-with-prefix {
      position: relative;
      display: flex;
      align-items: center;
    }

    .prefix {
      position: absolute;
      left: 0.75rem;
      color: #718096;
      font-weight: 600;
    }

    .input-with-prefix input {
      padding-left: 2rem;
    }

    .error-message {
      color: #e53e3e;
      font-size: 0.875rem;
    }

    .form-actions {
      display: flex;
      justify-content: flex-end;
      gap: 1rem;
      margin-top: 2rem;
      padding-top: 2rem;
      border-top: 1px solid #e2e8f0;
    }

    .btn {
      padding: 0.75rem 2rem;
      border: none;
      border-radius: 8px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s;
      font-size: 1rem;
    }

    .btn-primary {
      background: #4299e1;
      color: white;
    }

    .btn-primary:hover:not(:disabled) {
      background: #3182ce;
    }

    .btn-primary:disabled {
      opacity: 0.6;
      cursor: not-allowed;
    }

    .btn-secondary {
      background: #edf2f7;
      color: #1a202c;
    }

    .btn-secondary:hover {
      background: #e2e8f0;
    }

    .alert {
      padding: 1rem;
      border-radius: 8px;
      margin-top: 1rem;
    }

    .alert-error {
      background: #fed7d7;
      color: #742a2a;
    }

    @media (max-width: 768px) {
      .form-grid {
        grid-template-columns: 1fr;
      }

      .form-row {
        grid-template-columns: 1fr;
      }
    }
  `]
})
export class ProjectFormComponent implements OnInit {
  private fb = inject(FormBuilder);
  private projectService = inject(ProjectService);
  private clientService = inject(ClientService);
  private router = inject(Router);
  private route = inject(ActivatedRoute);

  projectForm!: FormGroup;
  clients: any[] = [];
  isEditMode = false;
  projectId?: string;
  saving = false;
  errorMessage = '';

  ngOnInit() {
    this.initForm();
    this.loadClients();
    
    this.projectId = this.route.snapshot.params['id'];
    if (this.projectId) {
      this.isEditMode = true;
      this.loadProject(this.projectId);
    }
  }

  initForm() {
    this.projectForm = this.fb.group({
      name: ['', Validators.required],
      description: [''],
      location: ['', Validators.required],
      city: [''],
      state: [''],
      clientId: ['', Validators.required],
      plannedStartDate: [''],
      plannedEndDate: [''],
      totalArea: [null],
      coveredArea: [null],
      contractAmount: [0, [Validators.required, Validators.min(0)]],
      priority: ['normal'],
      notes: ['']
    });
  }

  loadClients() {
    this.clientService.getAll().subscribe({
      next: (data) => {
        this.clients = data;
      },
      error: (err) => {
        console.error('Error loading clients:', err);
      }
    });
  }

  loadProject(id: string) {
    this.projectService.getById(id).subscribe({
      next: (project) => {
        this.projectForm.patchValue({
          name: project.name,
          description: project.description,
          location: project.location,
          city: project.city,
          state: project.state,
          clientId: project.clientId,
          plannedStartDate: project.plannedStartDate?.split('T')[0],
          plannedEndDate: project.plannedEndDate?.split('T')[0],
          totalArea: project.totalArea,
          contractAmount: project.contractAmount,
          priority: project.priority
        });
      },
      error: (err) => {
        this.errorMessage = 'Error al cargar el proyecto';
        console.error('Error:', err);
      }
    });
  }

  onSubmit() {
    if (this.projectForm.invalid) {
      Object.keys(this.projectForm.controls).forEach(key => {
        this.projectForm.get(key)?.markAsTouched();
      });
      return;
    }

    this.saving = true;
    this.errorMessage = '';

    const projectData: CreateProject = this.projectForm.value;

    if (this.isEditMode && this.projectId) {
      // Update logic would go here
      this.saving = false;
    } else {
      this.projectService.create(projectData).subscribe({
        next: (result) => {
          this.router.navigate(['/projects']);
        },
        error: (err) => {
          this.errorMessage = 'Error al crear el proyecto';
          this.saving = false;
          console.error('Error:', err);
        }
      });
    }
  }

  isFieldInvalid(fieldName: string): boolean {
    const field = this.projectForm.get(fieldName);
    return !!(field && field.invalid && field.touched);
  }

  goBack() {
    this.router.navigate(['/projects']);
  }
}
