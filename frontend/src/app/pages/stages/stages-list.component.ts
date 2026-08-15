import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';

interface Stage {
  id: string;
  name: string;
  projectName: string;
  projectId: string;
  status: string;
  progress: number;
  startDate: string;
  endDate: string;
}

@Component({
  selector: 'app-stages-list',
  standalone: true,
  imports: [CommonModule, RouterModule],
  template: `
    <div class="min-h-screen bg-gray-50 p-6">
      <div class="mb-6 flex justify-between items-center">
        <div>
          <h1 class="text-3xl font-bold text-gray-900">Etapas</h1>
          <p class="text-gray-600 mt-1">Gestiona las fases de los proyectos</p>
        </div>
        <button class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg font-medium transition-colors flex items-center gap-2">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
          </svg>
          Nueva Etapa
        </button>
      </div>

      <div class="bg-white rounded-lg shadow overflow-hidden">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Etapa</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Proyecto</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Estado</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Progreso</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Fechas</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Acciones</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr class="text-center">
              <td colspan="6" class="px-6 py-12 text-gray-500">
                <svg class="w-16 h-16 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path>
                </svg>
                <p>No hay etapas registradas</p>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  `
})
export class StagesListComponent implements OnInit {
  stages: Stage[] = [];

  ngOnInit() {
    // TODO: Cargar etapas desde el servicio
  }
}
