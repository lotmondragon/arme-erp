import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-footer',
  standalone: true,
  imports: [CommonModule],
  template: `
    <footer class="bg-white border-t border-gray-200 px-6 py-4">
      <div class="flex justify-between items-center text-sm text-gray-600">
        <p>&copy; 2025 ARME ERP. Todos los derechos reservados.</p>
        <p>Versión 1.0.0</p>
      </div>
    </footer>
  `
})
export class FooterComponent {}
