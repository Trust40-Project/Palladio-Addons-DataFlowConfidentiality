package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig.json;

import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonObjectBuilder;

import org.palladiosimulator.pcm.core.entity.Entity;

import de.uka.ipd.sdq.identifier.Identifier;

public interface IdentifierAdapterMixin {

    default JsonObject create(Identifier identifier) {
        return createJsonObjectBuilder(identifier).build();
    }
    
    default JsonObjectBuilder createJsonObjectBuilder(Identifier identifier) {
        JsonObjectBuilder builder = Json.createObjectBuilder()
            .add("id", identifier.getId());
        if (identifier instanceof Entity) {
            builder.add("name", ((Entity) identifier).getEntityName());
        }
        return builder;
    }

}
