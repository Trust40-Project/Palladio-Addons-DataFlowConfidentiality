package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig.json;

import javax.json.Json;
import javax.json.JsonArray;
import javax.json.JsonArrayBuilder;
import javax.json.JsonObject;
import javax.json.JsonObjectBuilder;
import javax.json.bind.adapter.JsonbAdapter;

import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysisResult.EntityInstance;

public class EntityInstanceAdapter implements JsonbAdapter<EntityInstance, JsonObject>, IdentifierAdapterMixin {

    @Override
    public EntityInstance adaptFromJson(JsonObject arg0) throws Exception {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public JsonObject adaptToJson(EntityInstance arg0) throws Exception {
        return createJsonObjectBuilder(arg0).build();
    }

    public JsonObjectBuilder createJsonObjectBuilder(EntityInstance arg0) throws Exception {
        JsonObject entity = create(arg0.getEntity());
        JsonArrayBuilder contextBuilder = Json.createArrayBuilder();
        arg0.getContext()
            .stream()
            .sorted((i1, i2) -> i1.getId()
                .compareTo(i2.getId()))
            .map(this::createJsonObjectBuilder)
            .forEach(contextBuilder::add);
        JsonArray context = contextBuilder.build();

        return Json.createObjectBuilder()
            .add("entity", entity)
            .add("context", context);
    }

}
