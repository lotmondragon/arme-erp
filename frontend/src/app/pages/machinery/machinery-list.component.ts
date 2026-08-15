import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';

@Component({
  selector: 'app-machinery-list',
  standalone: true,
  imports: [CommonModule, RouterModule],
  template: `
    <div class="min-h-screen bg-gray-50 p-6">
      <div class="mb-6 flex justify-between items-center">
        <div>
          <h1 class="text-3xl font-bold text-gray-900">Maquinaria</h1>
          <p class="text-gray-600 mt-1">Control de maquinaria y equipo</p>
        </div>
        <button class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg font-medium transition-colors flex items-center gap-2">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
          </svg>
          Nueva Maquinaria
        </button>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
        <div class="bg-white rounded-lg shadow p-6">
          <p class="text-sm text-gray-600">Total Equipos</p>
          <p class="text-2xl font-bold text-gray-900">0</p>
        </div>
        <div class="bg-white rounded-lg shadow p-6">
          <p class="text-sm text-gray-600">En Operación</p>
          <p class="text-2xl font-bold text-green-600">0</p>
        </div>
        <div class="bg-white rounded-lg shadow p-6">
          <p class="text-sm text-gray-600">En Mantenimiento</p>
          <p class="text-2xl font-bold text-orange-600">0</p>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow p-12 text-center">
        <svg class="w-16 h-16 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19.428 15.428a2 2 0 00-1.022-.547l-2.387-.477a6 6 0 00-3.86.517l-.318.158a6 6 0 01-3.86.517L6.05 15.21a2 2 0 00-1.806.547M8 4h8l-1 1v5.172a2 2 0 00.586 1.414l5 5c1.26 1.26.367 3.414-1.415 3.414H4.828c-1.782 0-2.674-2.154-1.414-3.414l5-5A2 2 0 009 10.172V5L8 4z"></path>
        </svg>
        <h3 class="text-xl font-semibold text-gray-900 mb-2">No hay maquinaria registrada</h3>
        <p class="text-gray-600">Comienza agregando equipos al sistema</p>
      </div>
    </div>
  `
})
export class MachineryListComponent {}
