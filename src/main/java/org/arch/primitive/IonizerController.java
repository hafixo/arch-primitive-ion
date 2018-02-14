package org.arch.primitive;

import org.arch.primitive.util.Ionizer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class IonizerController {

	private final Logger log = LoggerFactory.getLogger(this.getClass());

	@RequestMapping(value = "/adservers/update", method = RequestMethod.GET)
	@ResponseBody
	public String updateIonizer(Model model) {

		Ionizer adServers = ARCHServer.getIonizer();
		boolean updated = adServers.downloadIonizerList();
		adServers.loadListFromHostsFileFormat(null);

		if (!updated) {
			return "Something went wrong. Could not update ad servers list.";
		}
		return "Successfully updated. <br/>Loaded "+adServers.getNumberOfLoadedIonizer()+" ad servers.";

	}

}
