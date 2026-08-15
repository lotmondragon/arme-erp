import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';

@Component({
  selector: 'app-materials-list',
  standalone: true,
  imports: [CommonModule, RouterModule],
  template: `
    <div class="min-h-screen bg-gray-50 p-6">
      <div class="mb-6 flex justify-between items-center">
        <div>
          <h1 class="text-3xl font-bold text-gray-900">Materiales</h1>
          <p class="text-gray-600 mt-1">Control de inventario y materiales</p>
        </div>
        <button class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg font-medium transition-colors flex items-center gap-2">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
          </svg>
          Nuevo Material
        </button>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
        <div class="bg-white rounded-lg shadow p-6">
          <p class="text-sm text-gray-600">Total Materiales</p>
          <p class="text-2xl font-bold text-gray-900">0</p>
        </div>
        <div class="bg-white rounded-lg shadow p-6">
          <p class="text-sm text-gray-600">En Stock</p>
          <p class="text-2xl font-bold text-green-600">0</p>
        </div>
        <div class="bg-white rounded-lg shadow p-6">
          <p class="text-sm text-gray-600">Stock Bajo</p>
          <p class="text-2xl font-bold text-orange-600">0</p>
        </div>
        <div class="bg-white rounded-lg shadow p-6">
          <p class="text-sm text-gray-600">Sin Stock</p>
          <p class="text-2xl font-bold text-red-600">0</p>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow p-12 text-center">
        <svg class="w-16 h-16 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"></path>
        </svg>
        <h3 class="text-xl font-semibold text-gray-900 mb-2">No hay materiales registrados</h3>
        <p class="text-gray-600">Comienza agregando materiales al inventario</p>
      </div>
    </div>
  `
})
export class MaterialsListComponent {}
