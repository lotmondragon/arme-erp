import { Component, Output, EventEmitter, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';

@Component({
  selector: 'app-navbar',
  standalone: true,
  imports: [CommonModule, RouterModule],
  template: `
    <header class="bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between sticky top-0 z-10">
      <div class="flex items-center gap-4 flex-1">
        <button 
          (click)="toggleSidebar.emit()"
          class="lg:hidden p-2 hover:bg-gray-100 rounded-lg">
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
          </svg>
        </button>

        <div class="relative max-w-md flex-1">
          <input 
            type="search"
            placeholder="Buscar..."
            class="w-full px-4 py-2 pl-10 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
          <svg class="w-5 h-5 text-gray-400 absolute left-3 top-2.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
          </svg>
        </div>
      </div>

      <div class="flex items-center gap-4">
        <button class="relative p-2 hover:bg-gray-100 rounded-lg">
          <svg class="w-6 h-6 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"></path>
          </svg>
          <span class="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full"></span>
        </button>

        <div class="relative">
          <button 
            (click)="toggleUserMenu()"
            class="flex items-center gap-3 p-2 hover:bg-gray-100 rounded-lg">
            <div class="w-8 h-8 bg-blue-600 rounded-full flex items-center justify-center text-white font-semibold">
              A
            </div>
            <div class="hidden md:block text-left">
              <p class="text-sm font-medium text-gray-900">Admin</p>
              <p class="text-xs text-gray-500">Administrador</p>
            </div>
            <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
            </svg>
          </button>

          @if (userMenuOpen()) {
            <div class="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg border border-gray-200 py-1">
              <a routerLink="/settings/profile" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                Mi Perfil
              </a>
              <a routerLink="/settings" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                Configuración
              </a>
              <hr class="my-1">
              <button 
                (click)="logout()"
                class="w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-gray-100">
                Cerrar Sesión
              </button>
            </div>
          }
        </div>
      </div>
    </header>
  `
})
export class NavbarComponent {
  @Output() toggleSidebar = new EventEmitter<void>();
  
  userMenuOpen = signal(false);

  toggleUserMenu() {
    this.userMenuOpen.update(v => !v);
  }

  logout() {
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
    window.location.href = '/login';
  }
}
