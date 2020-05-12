package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.function.Supplier;
import java.util.Map.Entry;
import java.util.stream.Collectors;

import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysisResult;
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysisResult.DataFlowGraph;
import org.palladiosimulator.pcm.core.entity.Entity;
import org.palladiosimulator.pcm.repository.DataType;
import org.palladiosimulator.pcm.repository.PrimitiveDataType;
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall;

public class DataTypeUsageResultConverter {

    public static class DataFlowGraphRepresentation {

    }
    
    public static class DataFlowGraphNode {
        
    }

    public static class DataTypeUsageRepresentation {

        private final Collection<DataTypeRepresentation> readDataTypes;
        private final Collection<DataTypeRepresentation> writtenDataTypes;
        private final DataFlowGraphRepresentation dataFlowGraph;

        public DataTypeUsageRepresentation(Collection<DataTypeRepresentation> readDataTypes,
                Collection<DataTypeRepresentation> writtenDataTypes, DataFlowGraphRepresentation dataFlowGraph) {
            super();
            this.readDataTypes = readDataTypes;
            this.writtenDataTypes = writtenDataTypes;
            this.dataFlowGraph = dataFlowGraph;
        }

        public Collection<DataTypeRepresentation> getReadDataTypes() {
            return readDataTypes;
        }

        public Collection<DataTypeRepresentation> getWrittenDataTypes() {
            return writtenDataTypes;
        }

        public DataFlowGraphRepresentation getDataFlowGraph() {
            return dataFlowGraph;
        }

    }

    public static class EntryLevelSystemCallResult implements Comparable<EntryLevelSystemCallResult> {
        private final EntryLevelSystemCallRepresentation entryLevelSystemCall;
        private final List<DataTypeRepresentation> readDataTypes;
        private final List<DataTypeRepresentation> writeDataTypes;

        public EntryLevelSystemCallResult(EntryLevelSystemCallRepresentation entryLevelSystemCall,
                List<DataTypeRepresentation> readDataTypes, List<DataTypeRepresentation> writeDataTypes) {
            super();
            this.entryLevelSystemCall = entryLevelSystemCall;
            this.readDataTypes = readDataTypes;
            this.writeDataTypes = writeDataTypes;
        }

        public EntryLevelSystemCallRepresentation getEntryLevelSystemCall() {
            return entryLevelSystemCall;
        }

        public List<DataTypeRepresentation> getReadDataTypes() {
            return readDataTypes;
        }

        public List<DataTypeRepresentation> getWriteDataTypes() {
            return writeDataTypes;
        }

        @Override
        public int compareTo(EntryLevelSystemCallResult o) {
            return getEntryLevelSystemCall().compareTo(o.getEntryLevelSystemCall());
        }

    }

    public static class EntityRepresentation implements Comparable<EntityRepresentation> {
        private final String identifier;
        private final String name;

        public EntityRepresentation(String identifier, String name) {
            super();
            this.identifier = identifier;
            this.name = name;
        }

        public String getIdentifier() {
            return identifier;
        }

        public String getName() {
            return name;
        }

        @Override
        public int compareTo(EntityRepresentation o) {
            return compare(this::getName, o::getName, this::getIdentifier, o::getIdentifier);
        }

    }
    
    public static class EntityRepresentationWithContext extends EntityRepresentation {
        private final Collection<EntityRepresentation> context;

        public EntityRepresentationWithContext(String identifier, String name,
                Collection<EntityRepresentation> context) {
            super(identifier, name);
            this.context = context;
        }

        public Collection<EntityRepresentation> getContext() {
            return context;
        }

        @Override
        public int compareTo(EntityRepresentation o) {
            int result =  super.compareTo(o);
            if (result == 0 && o instanceof EntityRepresentationWithContext) {
                String ownContextString = context.stream().map(Object::toString).collect(Collectors.joining());
                String otherContextString = ((EntityRepresentationWithContext)o).getContext().stream().map(Object::toString).collect(Collectors.joining());
                return ownContextString.compareTo(otherContextString);
            }
            return result;
        }
        
        
    }

    public static class EntryLevelSystemCallRepresentation implements Comparable<EntryLevelSystemCallRepresentation> {
        private final String name;
        private final String id;

        public EntryLevelSystemCallRepresentation(String name, String id) {
            super();
            this.name = name;
            this.id = id;
        }

        public String getName() {
            return name;
        }

        public String getId() {
            return id;
        }

        @Override
        public int compareTo(EntryLevelSystemCallRepresentation o) {
            return compare(this::getName, o::getName, this::getId, o::getId);
        }

    }

    protected static int compare(Supplier<String> name1, Supplier<String> name2, Supplier<String> id1,
            Supplier<String> id2) {
        int result = name1.get()
            .compareTo(name2.get());
        if (result != 0) {
            return result;
        }

        return Optional.ofNullable(id1.get())
            .map(id -> id.compareTo(id2.get()))
            .orElse(0);
    }

    public static class DataTypeRepresentation implements Comparable<DataTypeRepresentation> {
        private final String name;
        private final String id;

        public DataTypeRepresentation(String name, String id) {
            super();
            this.name = name;
            this.id = id;
        }

        public String getName() {
            return name;
        }

        public String getId() {
            return id;
        }

        @Override
        public int compareTo(DataTypeRepresentation o) {
            return compare(this::getName, o::getName, this::getId, o::getId);
        }

    }

    private final Map<EntryLevelSystemCall, Collection<DataTypeUsageAnalysisResult>> original;

    public DataTypeUsageResultConverter(Map<EntryLevelSystemCall, Collection<DataTypeUsageAnalysisResult>> original) {
        this.original = original;
    }

    public List<EntryLevelSystemCallResult> getConversionResult() {
        List<EntryLevelSystemCallResult> results = new ArrayList<>();
//        for (Entry<EntryLevelSystemCall, Collection<DataTypeUsageAnalysisResult>> originalEntry : original.entrySet()) {
//            EntryLevelSystemCallRepresentation elsc = convertElsc(originalEntry.getKey());
//            Collection<DataTypeUsageAnalysisResult> dataTypeUsages = originalEntry.getValue();
//
//            List<DataTypeRepresentation> readDataTypes = convert(originalEntry.getValue()
//                .getReadDataTypes());
//            List<DataTypeRepresentation> writeDataTypes = convert(originalEntry.getValue()
//                .getWriteDataTypes());
//            results.add(new EntryLevelSystemCallResult(elsc, readDataTypes, writeDataTypes));
//        }
//        Collections.sort(results);
        return results;
    }

    protected EntryLevelSystemCallRepresentation convertElsc(EntryLevelSystemCall elsc) {
        return new EntryLevelSystemCallRepresentation(elsc.getEntityName(), elsc.getId());
    }

    protected List<DataTypeRepresentation> convert(Collection<DataType> dataTypes) {
        return dataTypes.stream()
            .map(this::convert)
            .sorted()
            .collect(Collectors.toList());
    }

    protected DataTypeRepresentation convert(DataType dataType) {
        if (dataType instanceof PrimitiveDataType) {
            String name = ((PrimitiveDataType) dataType).getType()
                .getName();
            return new DataTypeRepresentation(name, null);
        }
        Entity dataTypeEntity = (Entity) dataType;
        return new DataTypeRepresentation(dataTypeEntity.getEntityName(), dataTypeEntity.getId());
    }

}
