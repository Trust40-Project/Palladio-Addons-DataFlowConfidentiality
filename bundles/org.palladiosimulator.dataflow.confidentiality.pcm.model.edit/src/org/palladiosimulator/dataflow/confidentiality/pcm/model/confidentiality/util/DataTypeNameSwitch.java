package org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.util;

import java.util.Optional;

import org.palladiosimulator.pcm.repository.CollectionDataType;
import org.palladiosimulator.pcm.repository.CompositeDataType;
import org.palladiosimulator.pcm.repository.DataType;
import org.palladiosimulator.pcm.repository.PrimitiveDataType;
import org.palladiosimulator.pcm.repository.util.RepositorySwitch;

public class DataTypeNameSwitch extends RepositorySwitch<String> {

    @Override
    public String casePrimitiveDataType(PrimitiveDataType object) {
        return object.getType()
            .getName();
    }

    @Override
    public String caseCollectionDataType(CollectionDataType object) {
        return object.getEntityName();
    }

    @Override
    public String caseCompositeDataType(CompositeDataType object) {
        return object.getEntityName();
    }

    public static Optional<String> getName(DataType dataType) {
        return Optional.ofNullable(new DataTypeNameSwitch().doSwitch(dataType));
    }
}