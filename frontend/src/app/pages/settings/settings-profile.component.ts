import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-settings-profile',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="min-h-screen bg-gray-50 p-6">
      <div class="max-w-4xl mx-auto">
        <h1 class="text-3xl font-bold text-gray-900 mb-6">Mi Perfil</h1>

        <div class="bg-white rounded-lg shadow p-6 mb-6">
          <div class="flex items-center gap-6 mb-6">
            <div class="w-24 h-24 bg-blue-600 rounded-full flex items-center justify-center text-white text-3xl font-bold">
              A
            </div>
            <div>
              <h2 class="text-2xl font-bold text-gray-900">Admin Usuario</h2>
              <p class="text-gray-600">admin@arme.com</p>
              <span class="inline-block mt-2 px-3 py-1 bg-blue-100 text-blue-800 text-sm rounded-full">Administrador</span>
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Nombre</label>
              <input type="text" value="Admin" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Apellido</label>
              <input type="text" value="Usuario" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Email</label>
              <input type="email" value="admin@arme.com" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Teléfono</label>
              <input type="tel" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
            </div>
          </div>

          <div class="flex justify-end gap-4 mt-6 pt-6 border-t">
            <button class="px-6 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50">
              Cancelar
            </button>
            <button class="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
              Guardar Cambios
            </button>
          </div>
        </div>

        <div class="bg-white rounded-lg shadow p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">Cambiar Contraseña</h3>
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Contraseña Actual</label>
              <input type="password" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Nueva Contraseña</label>
              <input type="password" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Confirmar Nueva Contraseña</label>
              <input type="password" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
            </div>
          </div>

          <div class="flex justify-end mt-6">
            <button class="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
              Actualizar Contraseña
            </button>
          </div>
        </div>
      </div>
    </div>
  `
})
export class SettingsProfileComponent {}
