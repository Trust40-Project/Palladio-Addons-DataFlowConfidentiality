package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig.json;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.stream.Collectors;

import javax.json.bind.annotation.JsonbPropertyOrder;
import javax.json.bind.config.PropertyOrderStrategy;

import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysisResult;
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysisResult.DataFlowGraph;
import org.palladiosimulator.pcm.repository.DataType;
import org.palladiosimulator.pcm.repository.PrimitiveDataType;
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall;

import de.uka.ipd.sdq.identifier.Identifier;

@JsonbPropertyOrder(PropertyOrderStrategy.ANY)
public class ElscDataTypeUsages {

    @JsonbPropertyOrder(PropertyOrderStrategy.ANY)
    public static class ElscDataTypeUsage {
        private final EntryLevelSystemCall entryLevelSystemCall;
        private final Collection<DataType> readDataTypes;
        private final Collection<DataType> writeDataTypes;
        private final int dataFlowGraphId;

        public ElscDataTypeUsage(EntryLevelSystemCall entryLevelSystemCall, Collection<DataType> readDataTypes,
                Collection<DataType> writeDataTypes, int dataFlowGraphId) {
            super();
            this.entryLevelSystemCall = entryLevelSystemCall;
            this.readDataTypes = readDataTypes;
            this.writeDataTypes = writeDataTypes;
            this.dataFlowGraphId = dataFlowGraphId;
        }

        public EntryLevelSystemCall getEntryLevelSystemCall() {
            return entryLevelSystemCall;
        }

        public Collection<DataType> getReadDataTypes() {
            return readDataTypes;
        }

        public Collection<DataType> getWriteDataTypes() {
            return writeDataTypes;
        }

        public int getDataFlowGraphId() {
            return dataFlowGraphId;
        }

    }

    private final List<ElscDataTypeUsage> dataTypeUsage;
    private final List<DataFlowGraph> dataFlowGraphs;

    public ElscDataTypeUsages(Map<EntryLevelSystemCall, Collection<DataTypeUsageAnalysisResult>> original) {
        this.dataFlowGraphs = createDataFlowGraphs(original);
        this.dataTypeUsage = createElscDataTypeUsage(original, dataFlowGraphs);
    }

    private static String getIdentifierChain(Collection<DataType> dts) {
        return dts.stream()
            .map(ElscDataTypeUsages::getIdentifier)
            .sorted()
            .collect(Collectors.joining());
    }

    private static String getIdentifier(DataType dt) {
        if (dt instanceof PrimitiveDataType) {
            return ((PrimitiveDataType) dt).getType()
                .getName();
        }
        return ((Identifier) dt).getId();
    }

    private static int compare(DataTypeUsageAnalysisResult r1, DataTypeUsageAnalysisResult r2) {
        int comparison = getIdentifierChain(r1.getReadDataTypes()).compareTo(getIdentifierChain(r2.getReadDataTypes()));
        if (comparison != 0) {
            return comparison;
        }
        return getIdentifierChain(r1.getWriteDataTypes()).compareTo(getIdentifierChain(r2.getWriteDataTypes()));
    }

    private List<DataFlowGraph> createDataFlowGraphs(
            Map<EntryLevelSystemCall, Collection<DataTypeUsageAnalysisResult>> original) {
        return original.entrySet()
            .stream()
            .sorted((e1, e2) -> e1.getKey()
                .getId()
                .compareTo(e2.getKey()
                    .getId()))
            .map(Entry::getValue)
            .map(Collection::stream)
            .flatMap(s -> s.sorted(ElscDataTypeUsages::compare))
            .map(DataTypeUsageAnalysisResult::getDataFlowGraph)
            .filter(g -> !g.getNodes()
                .isEmpty())
            .collect(Collectors.toList());
    }

    private static List<ElscDataTypeUsage> createElscDataTypeUsage(
            Map<EntryLevelSystemCall, Collection<DataTypeUsageAnalysisResult>> original,
            List<DataFlowGraph> dataflowGraphs) {
        List<ElscDataTypeUsage> result = new ArrayList<>();
        List<EntryLevelSystemCall> elscs = new ArrayList<>(original.keySet());
        elscs.sort((e1, e2) -> e1.getId()
            .compareTo(e2.getId()));
        for (EntryLevelSystemCall elsc : elscs) {
            for (DataTypeUsageAnalysisResult usage : original.get(elsc)) {
                result.add(new ElscDataTypeUsage(elsc, usage.getReadDataTypes(), usage.getWriteDataTypes(),
                        dataflowGraphs.indexOf(usage.getDataFlowGraph())));
            }
        }
        return result;
    }

    public List<ElscDataTypeUsage> getDataTypeUsage() {
        return dataTypeUsage;
    }

    public List<DataFlowGraph> getDataFlowGraphs() {
        return dataFlowGraphs;
    }

}
