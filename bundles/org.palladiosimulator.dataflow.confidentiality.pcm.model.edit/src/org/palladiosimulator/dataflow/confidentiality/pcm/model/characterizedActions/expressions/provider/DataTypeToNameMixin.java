package org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.expressions.provider;

import org.palladiosimulator.pcm.core.entity.Entity;
import org.palladiosimulator.pcm.repository.DataType;
import org.palladiosimulator.pcm.repository.PrimitiveDataType;

public interface DataTypeToNameMixin {

    default String getName(DataType dataType) {
        if (dataType instanceof Entity) {
            return ((Entity) dataType).getEntityName();
        }
        if (dataType instanceof PrimitiveDataType) {
            return ((PrimitiveDataType) dataType).getType().getLiteral();
        }
        return null;
    }
    
}
