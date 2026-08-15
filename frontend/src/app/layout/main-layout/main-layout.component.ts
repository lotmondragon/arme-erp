import { Component, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterOutlet } from '@angular/router';
import { SidebarComponent } from '../sidebar/sidebar.component';
import { NavbarComponent } from '../navbar/navbar.component';
import { FooterComponent } from '../footer/footer.component';

@Component({
  selector: 'app-main-layout',
  standalone: true,
  imports: [CommonModule, RouterOutlet, SidebarComponent, NavbarComponent, FooterComponent],
  template: `
    <div class="min-h-screen bg-gray-50 flex">
      <app-sidebar 
        [collapsed]="sidebarCollapsed()"
        (toggleSidebar)="toggleSidebar()">
      </app-sidebar>

      <div class="flex-1 flex flex-col">
        <app-navbar (toggleSidebar)="toggleSidebar()"></app-navbar>
        
        <main class="flex-1 overflow-auto">
          <router-outlet></router-outlet>
        </main>

        <app-footer></app-footer>
      </div>
    </div>
  `
})
export class MainLayoutComponent {
  sidebarCollapsed = signal(false);

  toggleSidebar() {
    this.sidebarCollapsed.update(v => !v);
  }
}
