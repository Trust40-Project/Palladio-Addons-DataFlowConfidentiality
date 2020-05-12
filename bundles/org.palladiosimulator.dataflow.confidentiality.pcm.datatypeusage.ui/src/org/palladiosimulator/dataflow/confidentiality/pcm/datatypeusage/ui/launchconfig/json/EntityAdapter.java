package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig.json;

import javax.json.JsonObject;
import javax.json.bind.adapter.JsonbAdapter;

import org.palladiosimulator.pcm.core.entity.Entity;

public class EntityAdapter implements JsonbAdapter<Entity, JsonObject>, IdentifierAdapterMixin {

    @Override
    public Entity adaptFromJson(JsonObject arg0) throws Exception {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public JsonObject adaptToJson(Entity arg0) throws Exception {
        return create(arg0);
    }

}
