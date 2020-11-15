package org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.expression.provider;

import java.util.Optional;

import org.eclipse.emf.common.notify.AdapterFactory;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.expression.LhsEnumCharacteristicReference;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.CharacteristicType;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.Literal;

public class LhsEnumCharacteristicReferenceItemProvider extends LhsEnumCharacteristicReferenceItemProviderGen {

    public LhsEnumCharacteristicReferenceItemProvider(AdapterFactory adapterFactory) {
        super(adapterFactory);
    }

    @Override
    public String getText(Object object) {
        if (object instanceof LhsEnumCharacteristicReference) {
            var reference = (LhsEnumCharacteristicReference) object;
            var typeSegment = Optional.ofNullable(reference.getCharacteristicType())
                .map(CharacteristicType::getName)
                .orElse("*");
            var literalSegment = Optional.ofNullable(reference.getLiteral())
                .map(Literal::getName)
                .orElse("*");
            return String.format("%s.%s", typeSegment, literalSegment);
        }
        return super.getText(object);
    }

}
