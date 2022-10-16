#!/bin/bash

(
  cd /etc/wireguard
  umask 077
  wg genkey | tee prvk | wg pubkey > pubk
  wg genpsk > pshk
)
