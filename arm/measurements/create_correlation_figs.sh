#!/bin/sh

cpu="ARM" ipc="grpc" node="server" correlation="pearson" runipy correlation_energy_time.ipynb
cpu="ARM" ipc="grpc" node="client" correlation="pearson" runipy correlation_energy_time.ipynb
cpu="ARM" ipc="rpc" node="server" correlation="pearson" runipy correlation_energy_time.ipynb
cpu="ARM" ipc="rpc" node="client" correlation="pearson" runipy correlation_energy_time.ipynb
cpu="ARM" ipc="rest" node="server" correlation="pearson" runipy correlation_energy_time.ipynb
cpu="ARM" ipc="rest" node="client" correlation="pearson" runipy correlation_energy_time.ipynb
