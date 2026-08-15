import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';
import { ClientService } from '../../services/client.service';

@Component({
  selector: 'app-client-form',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  template: `
    <div class="min-h-screen bg-gray-50 p-6">
      <div class="max-w-4xl mx-auto">
        <!-- Header -->
        <div class="mb-6">
          <h1 class="text-3xl font-bold text-gray-900">{{ isEditMode ? 'Editar' : 'Nuevo' }} Cliente</h1>
          <p class="text-gray-600 mt-1">Complete la información del cliente</p>
        </div>

        <!-- Form -->
        <form [formGroup]="clientForm" (ngSubmit)="onSubmit()" class="bg-white rounded-lg shadow p-6">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Nombre de la Empresa -->
            <div class="md:col-span-2">
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Nombre de la Empresa *
              </label>
              <input
                type="text"
                formControlName="companyName"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="Ej: Constructora ABC S.A. de C.V.">
              @if (clientForm.get('companyName')?.invalid && clientForm.get('companyName')?.touched) {
                <p class="mt-1 text-sm text-red-600">El nombre de la empresa es requerido</p>
              }
            </div>

            <!-- Nombre del Contacto -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Nombre del Contacto *
              </label>
              <input
                type="text"
                formControlName="contactName"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="Ej: Juan Pérez">
              @if (clientForm.get('contactName')?.invalid && clientForm.get('contactName')?.touched) {
                <p class="mt-1 text-sm text-red-600">El nombre del contacto es requerido</p>
              }
            </div>

            <!-- Email -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Email *
              </label>
              <input
                type="email"
                formControlName="email"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="contacto@empresa.com">
              @if (clientForm.get('email')?.invalid && clientForm.get('email')?.touched) {
                <p class="mt-1 text-sm text-red-600">Email inválido</p>
              }
            </div>

            <!-- Teléfono -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Teléfono *
              </label>
              <input
                type="tel"
                formControlName="phone"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="(55) 1234-5678">
              @if (clientForm.get('phone')?.invalid && clientForm.get('phone')?.touched) {
                <p class="mt-1 text-sm text-red-600">El teléfono es requerido</p>
              }
            </div>

            <!-- RFC -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                RFC
              </label>
              <input
                type="text"
                formControlName="taxId"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="ABC123456XXX">
            </div>

            <!-- Dirección -->
            <div class="md:col-span-2">
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Dirección
              </label>
              <textarea
                formControlName="address"
                rows="3"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="Calle, número, colonia, ciudad, estado, CP"></textarea>
            </div>

            <!-- Notas -->
            <div class="md:col-span-2">
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Notas
              </label>
              <textarea
                formControlName="notes"
                rows="3"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="Información adicional del cliente"></textarea>
            </div>
          </div>

          <!-- Actions -->
          <div class="flex justify-end gap-4 mt-6 pt-6 border-t">
            <button
              type="button"
              (click)="onCancel()"
              class="px-6 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors">
              Cancelar
            </button>
            <button
              type="submit"
              [disabled]="clientForm.invalid || loading"
              class="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed">
              {{ loading ? 'Guardando...' : (isEditMode ? 'Actualizar' : 'Crear') }} Cliente
            </button>
          </div>
        </form>
      </div>
    </div>
  `
})
export class ClientFormComponent implements OnInit {
  private fb = inject(FormBuilder);
  private router = inject(Router);
  private route = inject(ActivatedRoute);
  private clientService = inject(ClientService);

  clientForm: FormGroup;
  loading = false;
  isEditMode = false;
  clientId: string | null = null;

  constructor() {
    this.clientForm = this.fb.group({
      companyName: ['', Validators.required],
      contactName: ['', Validators.required],
      email: ['', [Validators.required, Validators.email]],
      phone: ['', Validators.required],
      taxId: [''],
      address: [''],
      notes: ['']
    });
  }

  ngOnInit() {
    this.clientId = this.route.snapshot.paramMap.get('id');
    this.isEditMode = !!this.clientId;

    if (this.isEditMode && this.clientId) {
      this.loadClient(this.clientId);
    }
  }

  loadClient(id: string) {
    this.loading = true;
    this.clientService.getById(id).subscribe({
      next: (client) => {
        this.clientForm.patchValue(client);
        this.loading = false;
      },
      error: (error) => {
        console.error('Error loading client:', error);
        this.loading = false;
      }
    });
  }

  onSubmit() {
    if (this.clientForm.valid) {
      this.loading = true;
      const clientData = this.clientForm.value;

      const request = this.isEditMode && this.clientId
        ? this.clientService.update(this.clientId, clientData)
        : this.clientService.create(clientData);

      request.subscribe({
        next: () => {
          this.router.navigate(['/clients']);
        },
        error: (error) => {
          console.error('Error saving client:', error);
          this.loading = false;
        }
      });
    }
  }

  onCancel() {
    this.router.navigate(['/clients']);
  }
}
