#!/bin/sh

cpu="Intel" ipc="grpc" node="server" correlation="pearson" runipy correlation_energy_and_time.ipynb
cpu="Intel" ipc="grpc" node="client" correlation="pearson" runipy correlation_energy_and_time.ipynb
cpu="Intel" ipc="rpc" node="server" correlation="pearson" runipy correlation_energy_and_time.ipynb
cpu="Intel" ipc="rpc" node="client" correlation="pearson" runipy correlation_energy_and_time.ipynb
cpu="Intel" ipc="rest" node="server" correlation="pearson" runipy correlation_energy_and_time.ipynb
cpu="Intel" ipc="rest" node="client" correlation="pearson" runipy correlation_energy_and_time.ipynb
