import { Routes } from '@angular/router';
import { authGuard } from './auth/auth.guard';

export const routes: Routes = [
  // Auth routes (no layout)
  {
    path: 'login',
    loadComponent: () => import('./pages/login/login').then(m => m.Login)
  },
  
  // Protected routes (with layout)
  {
    path: '',
    loadComponent: () => import('./layout/main-layout/main-layout.component').then(m => m.MainLayoutComponent),
    canActivate: [authGuard],
    children: [
      {
        path: 'dashboard',
        loadComponent: () => import('./pages/dashboard/dashboard').then(m => m.Dashboard)
      },
      {
        path: 'clients',
        children: [
          {
            path: '',
            loadComponent: () => import('./pages/clients/clients').then(m => m.Clients)
          },
          {
            path: 'new',
            loadComponent: () => import('./pages/clients/client-form.component').then(m => m.ClientFormComponent)
          },
          {
            path: ':id',
            loadComponent: () => import('./pages/clients/client-detail.component').then(m => m.ClientDetailComponent)
          },
          {
            path: ':id/edit',
            loadComponent: () => import('./pages/clients/client-form.component').then(m => m.ClientFormComponent)
          }
        ]
      },
      {
        path: 'projects',
        children: [
          {
            path: '',
            loadComponent: () => import('./pages/projects/projects-list.component').then(m => m.ProjectsListComponent)
          },
          {
            path: 'new',
            loadComponent: () => import('./pages/projects/project-form.component').then(m => m.ProjectFormComponent)
          },
          {
            path: ':id',
            loadComponent: () => import('./pages/projects/project-detail.component').then(m => m.ProjectDetailComponent)
          },
          {
            path: ':id/edit',
            loadComponent: () => import('./pages/projects/project-form.component').then(m => m.ProjectFormComponent)
          }
        ]
      },
      {
        path: 'stages',
        loadComponent: () => import('./pages/stages/stages-list.component').then(m => m.StagesListComponent)
      },
      {
        path: 'contracts',
        loadComponent: () => import('./pages/contracts/contracts-list.component').then(m => m.ContractsListComponent)
      },
      {
        path: 'payments',
        loadComponent: () => import('./pages/payments/payments-list.component').then(m => m.PaymentsListComponent)
      },
      {
        path: 'employees',
        loadComponent: () => import('./pages/employees/employees-list.component').then(m => m.EmployeesListComponent)
      },
      {
        path: 'providers',
        loadComponent: () => import('./pages/providers/providers-list.component').then(m => m.ProvidersListComponent)
      },
      {
        path: 'materials',
        loadComponent: () => import('./pages/materials/materials-list.component').then(m => m.MaterialsListComponent)
      },
      {
        path: 'machinery',
        loadComponent: () => import('./pages/machinery/machinery-list.component').then(m => m.MachineryListComponent)
      },
      {
        path: 'reports',
        loadComponent: () => import('./pages/reports/reports-dashboard.component').then(m => m.ReportsDashboardComponent)
      },
      {
        path: 'settings',
        children: [
          {
            path: 'profile',
            loadComponent: () => import('./pages/settings/settings-profile.component').then(m => m.SettingsProfileComponent)
          },
          {
            path: '',
            redirectTo: 'profile',
            pathMatch: 'full'
          }
        ]
      },
      {
        path: '',
        redirectTo: '/dashboard',
        pathMatch: 'full'
      }
    ]
  },
  
  // Wildcard
  {
    path: '**',
    redirectTo: '/dashboard'
  }
];
