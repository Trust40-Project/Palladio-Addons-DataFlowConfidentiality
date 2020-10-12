package org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.expression.provider;

import java.util.Optional;

import org.eclipse.emf.common.notify.AdapterFactory;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.expression.LhsDataTypeCharacteristicReference;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.util.DataTypeNameSwitch;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.CharacteristicType;

public class LhsDataTypeCharacteristicReferenceItemProvider extends LhsDataTypeCharacteristicReferenceItemProviderGen {

    public LhsDataTypeCharacteristicReferenceItemProvider(AdapterFactory adapterFactory) {
        super(adapterFactory);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String getText(Object object) {
        if (object instanceof LhsDataTypeCharacteristicReference) {
            var reference = (LhsDataTypeCharacteristicReference) object;
            var typeSegment = Optional.ofNullable(reference.getCharacteristicType())
                .map(CharacteristicType::getName)
                .orElse("*");
            var literalSegment = Optional.ofNullable(reference.getDataType())
                .flatMap(DataTypeNameSwitch::getName)
                .orElse("*");
            return String.format("%s.%s", typeSegment, literalSegment);
        }
        return super.getText(object);
    }

}
