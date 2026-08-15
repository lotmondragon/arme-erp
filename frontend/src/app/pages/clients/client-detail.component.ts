import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, ActivatedRoute } from '@angular/router';
import { ClientService, Client } from '../../services/client.service';

@Component({
  selector: 'app-client-detail',
  standalone: true,
  imports: [CommonModule, RouterModule],
  template: `
    <div class="min-h-screen bg-gray-50 p-6">
      @if (loading) {
        <div class="flex justify-center items-center h-64">
          <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
        </div>
      } @else if (client) {
        <div class="max-w-6xl mx-auto">
          <!-- Header -->
          <div class="mb-6 flex justify-between items-start">
            <div>
              <h1 class="text-3xl font-bold text-gray-900">{{ client.companyName }}</h1>
              <p class="text-gray-600 mt-1">{{ client.contactName }}</p>
            </div>
            <div class="flex gap-3">
              <button
                [routerLink]="['/clients', client.id, 'edit']"
                class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg transition-colors">
                Editar
              </button>
              <button
                (click)="deleteClient()"
                class="bg-red-600 hover:bg-red-700 text-white px-6 py-2 rounded-lg transition-colors">
                Eliminar
              </button>
            </div>
          </div>

          <!-- Info Cards -->
          <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
            <!-- Contact Info -->
            <div class="bg-white rounded-lg shadow p-6">
              <h3 class="text-lg font-semibold text-gray-900 mb-4">Información de Contacto</h3>
              <div class="space-y-3">
                <div class="flex items-center gap-3">
                  <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                  </svg>
                  <span class="text-sm text-gray-600">{{ client.email }}</span>
                </div>
                <div class="flex items-center gap-3">
                  <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"></path>
                  </svg>
                  <span class="text-sm text-gray-600">{{ client.phone }}</span>
                </div>
                @if (client.taxId) {
                  <div class="flex items-center gap-3">
                    <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                    </svg>
                    <span class="text-sm text-gray-600">RFC: {{ client.taxId }}</span>
                  </div>
                }
              </div>
            </div>

            <!-- Stats -->
            <div class="bg-white rounded-lg shadow p-6">
              <h3 class="text-lg font-semibold text-gray-900 mb-4">Estadísticas</h3>
              <div class="space-y-3">
                <div>
                  <p class="text-sm text-gray-600">Proyectos Activos</p>
                  <p class="text-2xl font-bold text-blue-600">0</p>
                </div>
                <div>
                  <p class="text-sm text-gray-600">Proyectos Totales</p>
                  <p class="text-2xl font-bold text-gray-900">0</p>
                </div>
              </div>
            </div>

            <!-- Financial -->
            <div class="bg-white rounded-lg shadow p-6">
              <h3 class="text-lg font-semibold text-gray-900 mb-4">Financiero</h3>
              <div class="space-y-3">
                <div>
                  <p class="text-sm text-gray-600">Total Facturado</p>
                  <p class="text-2xl font-bold text-green-600">$0.00</p>
                </div>
                <div>
                  <p class="text-sm text-gray-600">Pendiente de Pago</p>
                  <p class="text-2xl font-bold text-orange-600">$0.00</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Tabs -->
          <div class="bg-white rounded-lg shadow">
            <div class="border-b border-gray-200">
              <nav class="flex -mb-px">
                <button
                  (click)="activeTab = 'projects'"
                  [class.border-blue-600]="activeTab === 'projects'"
                  [class.text-blue-600]="activeTab === 'projects'"
                  class="px-6 py-4 border-b-2 font-medium text-sm">
                  Proyectos
                </button>
                <button
                  (click)="activeTab = 'invoices'"
                  [class.border-blue-600]="activeTab === 'invoices'"
                  [class.text-blue-600]="activeTab === 'invoices'"
                  class="px-6 py-4 border-b-2 font-medium text-sm">
                  Facturas
                </button>
                <button
                  (click)="activeTab = 'info'"
                  [class.border-blue-600]="activeTab === 'info'"
                  [class.text-blue-600]="activeTab === 'info'"
                  class="px-6 py-4 border-b-2 font-medium text-sm">
                  Información
                </button>
              </nav>
            </div>

            <div class="p-6">
              @if (activeTab === 'projects') {
                <div class="text-center py-12">
                  <svg class="w-16 h-16 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path>
                  </svg>
                  <p class="text-gray-600">No hay proyectos asociados</p>
                </div>
              } @else if (activeTab === 'invoices') {
                <div class="text-center py-12">
                  <svg class="w-16 h-16 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                  </svg>
                  <p class="text-gray-600">No hay facturas registradas</p>
                </div>
              } @else if (activeTab === 'info') {
                <div class="space-y-4">
                  @if (client.address) {
                    <div>
                      <h4 class="text-sm font-medium text-gray-700 mb-2">Dirección</h4>
                      <p class="text-gray-600">{{ client.address }}</p>
                    </div>
                  }
                  @if (client.notes) {
                    <div>
                      <h4 class="text-sm font-medium text-gray-700 mb-2">Notas</h4>
                      <p class="text-gray-600">{{ client.notes }}</p>
                    </div>
                  }
                  @if (!client.address && !client.notes) {
                    <p class="text-gray-600 text-center py-8">No hay información adicional</p>
                  }
                </div>
              }
            </div>
          </div>
        </div>
      }
    </div>
  `
})
export class ClientDetailComponent implements OnInit {
  private route = inject(ActivatedRoute);
  private clientService = inject(ClientService);

  client: Client | null = null;
  loading = true;
  activeTab = 'projects';

  ngOnInit() {
    const id = this.route.snapshot.paramMap.get('id');
    if (id) {
      this.loadClient(id);
    }
  }

  loadClient(id: string) {
    this.clientService.getById(id).subscribe({
      next: (client) => {
        this.client = client;
        this.loading = false;
      },
      error: (error) => {
        console.error('Error loading client:', error);
        this.loading = false;
      }
    });
  }

  deleteClient() {
    if (confirm('¿Está seguro de eliminar este cliente?') && this.client) {
      this.clientService.delete(this.client.id).subscribe({
        next: () => {
          window.location.href = '/clients';
        },
        error: (error) => {
          console.error('Error deleting client:', error);
        }
      });
    }
  }
}
