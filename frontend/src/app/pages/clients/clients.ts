import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { ClientService, Client } from '../../services/client.service';

@Component({
  selector: 'app-clients',
  imports: [CommonModule, RouterModule],
  templateUrl: './clients.html',
  styleUrl: './clients.scss'
})
export class Clients implements OnInit {
  private clientService = inject(ClientService);
  
  clients: Client[] = [];
  loading = true;
  error = '';

  ngOnInit() {
    this.loadClients();
  }

  loadClients() {
    this.loading = true;
    this.clientService.getAll().subscribe({
      next: (data) => {
        this.clients = data;
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Error al cargar clientes';
        this.loading = false;
        console.error(err);
      }
    });
  }

  deleteClient(id: string) {
    if (confirm('¿Está seguro de eliminar este cliente?')) {
      this.clientService.delete(id).subscribe({
        next: () => this.loadClients(),
        error: (err) => {
          alert('Error al eliminar cliente');
          console.error(err);
        }
      });
    }
  }
}
