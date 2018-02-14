package org.arch.primitive.security;

import org.arch.primitive.User;
import org.apache.commons.codec.digest.DigestUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.stereotype.Component;

import java.util.ArrayList;

@Component
public class ARCHAuthenticationProvider implements AuthenticationProvider {
	private final Logger log = LoggerFactory.getLogger(this.getClass());

	@Override
	public Authentication authenticate(Authentication authentication)
	throws AuthenticationException {

		String name = authentication.getName();
		String password = DigestUtils.md5Hex(authentication.getCredentials().toString());

		User sabpUser = new User();
		if (name.equals(sabpUser.getUserName()) && password.equals(sabpUser.getPasswordHash())) {
			log.info("Successful login from user '"+name+"'");
			return new UsernamePasswordAuthenticationToken(name, password, new ArrayList<>());
		} else {
			log.warn("Invalid login attempt (user: "+name+")");
			return null;
		}
	}

	@Override
	public boolean supports(Class<?> authentication) {
		return authentication.equals(
		UsernamePasswordAuthenticationToken.class);
	}
}
