module vwebui

#flag -DWEBUI_USE_TLS -DWEBUI_TLS -DNO_SSL_DL -DOPENSSL_API_1_1
#flag -lssl -lcrypto
#flag windows -lBcrypt

fn set_tls_certificate(certificate_pem string, private_key_pem string) ! {
	if !C.webui_set_tls_certificate(&char(certificate_pem.str), &char(private_key_pem.str)) {
		return error('error: failed to set TLS certificate')
	}
}
