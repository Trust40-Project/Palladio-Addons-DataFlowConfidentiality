package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig.json;

import javax.json.Json;
import javax.json.JsonObject;
import javax.json.bind.adapter.JsonbAdapter;

import org.palladiosimulator.pcm.repository.DataType;
import org.palladiosimulator.pcm.repository.PrimitiveDataType;

import de.uka.ipd.sdq.identifier.Identifier;

public class DataTypeAdapter implements JsonbAdapter<DataType, JsonObject>, IdentifierAdapterMixin {

    @Override
    public DataType adaptFromJson(JsonObject arg0) throws Exception {
        return null;
    }

    @Override
    public JsonObject adaptToJson(DataType arg0) throws Exception {
        if (arg0 instanceof PrimitiveDataType) {
            return Json.createObjectBuilder().add("name", ((PrimitiveDataType)arg0).getType().getName()).build();
        }
        return create((Identifier)arg0);
    }

}
