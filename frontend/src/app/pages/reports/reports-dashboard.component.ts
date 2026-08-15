import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-reports-dashboard',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="min-h-screen bg-gray-50 p-6">
      <div class="mb-6">
        <h1 class="text-3xl font-bold text-gray-900">Reportes</h1>
        <p class="text-gray-600 mt-1">Análisis y reportes del sistema</p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <!-- Reporte de Proyectos -->
        <div class="bg-white rounded-lg shadow p-6 hover:shadow-lg transition-shadow cursor-pointer">
          <div class="flex items-center justify-between mb-4">
            <div class="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
              <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path>
              </svg>
            </div>
          </div>
          <h3 class="text-lg font-semibold text-gray-900 mb-2">Reporte de Proyectos</h3>
          <p class="text-sm text-gray-600">Estado y avance de todos los proyectos</p>
        </div>

        <!-- Reporte Financiero -->
        <div class="bg-white rounded-lg shadow p-6 hover:shadow-lg transition-shadow cursor-pointer">
          <div class="flex items-center justify-between mb-4">
            <div class="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
              <svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
              </svg>
            </div>
          </div>
          <h3 class="text-lg font-semibold text-gray-900 mb-2">Reporte Financiero</h3>
          <p class="text-sm text-gray-600">Ingresos, gastos y utilidades</p>
        </div>

        <!-- Reporte de Clientes -->
        <div class="bg-white rounded-lg shadow p-6 hover:shadow-lg transition-shadow cursor-pointer">
          <div class="flex items-center justify-between mb-4">
            <div class="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
              <svg class="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path>
              </svg>
            </div>
          </div>
          <h3 class="text-lg font-semibold text-gray-900 mb-2">Reporte de Clientes</h3>
          <p class="text-sm text-gray-600">Análisis de cartera de clientes</p>
        </div>

        <!-- Reporte de Materiales -->
        <div class="bg-white rounded-lg shadow p-6 hover:shadow-lg transition-shadow cursor-pointer">
          <div class="flex items-center justify-between mb-4">
            <div class="w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center">
              <svg class="w-6 h-6 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"></path>
              </svg>
            </div>
          </div>
          <h3 class="text-lg font-semibold text-gray-900 mb-2">Reporte de Materiales</h3>
          <p class="text-sm text-gray-600">Inventario y consumo de materiales</p>
        </div>

        <!-- Reporte de Personal -->
        <div class="bg-white rounded-lg shadow p-6 hover:shadow-lg transition-shadow cursor-pointer">
          <div class="flex items-center justify-between mb-4">
            <div class="w-12 h-12 bg-indigo-100 rounded-lg flex items-center justify-center">
              <svg class="w-6 h-6 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"></path>
              </svg>
            </div>
          </div>
          <h3 class="text-lg font-semibold text-gray-900 mb-2">Reporte de Personal</h3>
          <p class="text-sm text-gray-600">Asignaciones y productividad</p>
        </div>

        <!-- Reporte de Maquinaria -->
        <div class="bg-white rounded-lg shadow p-6 hover:shadow-lg transition-shadow cursor-pointer">
          <div class="flex items-center justify-between mb-4">
            <div class="w-12 h-12 bg-red-100 rounded-lg flex items-center justify-center">
              <svg class="w-6 h-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19.428 15.428a2 2 0 00-1.022-.547l-2.387-.477a6 6 0 00-3.86.517l-.318.158a6 6 0 01-3.86.517L6.05 15.21a2 2 0 00-1.806.547M8 4h8l-1 1v5.172a2 2 0 00.586 1.414l5 5c1.26 1.26.367 3.414-1.415 3.414H4.828c-1.782 0-2.674-2.154-1.414-3.414l5-5A2 2 0 009 10.172V5L8 4z"></path>
              </svg>
            </div>
          </div>
          <h3 class="text-lg font-semibold text-gray-900 mb-2">Reporte de Maquinaria</h3>
          <p class="text-sm text-gray-600">Uso y mantenimiento de equipos</p>
        </div>
      </div>
    </div>
  `
})
export class ReportsDashboardComponent {}
