package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig.json;

import java.util.ArrayList;
import java.util.List;

import javax.json.Json;
import javax.json.JsonArrayBuilder;
import javax.json.JsonObject;
import javax.json.JsonObjectBuilder;
import javax.json.bind.adapter.JsonbAdapter;

import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysisResult.DataFlowGraph;
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysisResult.EntityInstance;
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysisResult.EntityInstanceRelation;

public class DataFlowGraphAdapter implements JsonbAdapter<DataFlowGraph, JsonObject> {

    private final EntityInstanceAdapter entityInstanceHandler = new EntityInstanceAdapter();

    @Override
    public DataFlowGraph adaptFromJson(JsonObject arg0) throws Exception {
        return null;
    }

    @Override
    public JsonObject adaptToJson(DataFlowGraph arg0) throws Exception {
        JsonArrayBuilder nodesArrayBuilder = Json.createArrayBuilder();
        List<EntityInstance> nodeListSorted = new ArrayList<>(arg0.getNodes());
        nodeListSorted.sort((e1, e2) -> e1.getEntity()
            .getId()
            .compareTo(e2.getEntity()
                .getId()));
        for (int i = 0; i < nodeListSorted.size(); ++i) {
            JsonObjectBuilder nodeBuilder = Json.createObjectBuilder()
                .add("id", i)
                .add("element", entityInstanceHandler.createJsonObjectBuilder(nodeListSorted.get(i)));
            nodesArrayBuilder.add(nodeBuilder);
        }

        JsonArrayBuilder edgesArrayBuilder = Json.createArrayBuilder();
        List<EntityInstanceRelation> edgesSorted = new ArrayList<>(arg0.getEdges());
        edgesSorted.sort((e1, e2) -> {
            int e1FromNo = nodeListSorted.indexOf(e1.getFrom());
            int e2FromNo = nodeListSorted.indexOf(e2.getFrom());
            int fromResult = e1FromNo - e2FromNo;
            if (fromResult != 0) {
                return fromResult;
            }
            int e1ToNo = nodeListSorted.indexOf(e1.getTo());
            int e2ToNo = nodeListSorted.indexOf(e2.getTo());
            return e1ToNo - e2ToNo;
        });
        for (EntityInstanceRelation edge : edgesSorted) {

            int fromIndex = nodeListSorted.indexOf(edge.getFrom());
            int toIndex = nodeListSorted.indexOf(edge.getTo());
            JsonObjectBuilder edgeBuilder = Json.createObjectBuilder()
                .add("from", fromIndex)
                .add("to", toIndex);
            edgesArrayBuilder.add(edgeBuilder);
        }

        return Json.createObjectBuilder()
            .add("nodes", nodesArrayBuilder)
            .add("edges", edgesArrayBuilder)
            .build();
    }

}
