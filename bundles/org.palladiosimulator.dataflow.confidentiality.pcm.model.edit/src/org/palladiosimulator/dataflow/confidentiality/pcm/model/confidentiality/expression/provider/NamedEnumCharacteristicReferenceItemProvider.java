package org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.expression.provider;

import java.util.Optional;

import org.eclipse.emf.common.notify.AdapterFactory;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.expression.NamedEnumCharacteristicReference;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.CharacteristicType;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.Literal;

import de.uka.ipd.sdq.stoex.AbstractNamedReference;

public class NamedEnumCharacteristicReferenceItemProvider extends NamedEnumCharacteristicReferenceItemProviderGen {

    /**
     * {@inheritDoc}
     */
    public NamedEnumCharacteristicReferenceItemProvider(AdapterFactory adapterFactory) {
        super(adapterFactory);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String getText(Object object) {
        if (object instanceof NamedEnumCharacteristicReference) {
            var reference = (NamedEnumCharacteristicReference) object;
            var namePart = Optional.ofNullable(reference.getNamedReference())
                .map(AbstractNamedReference::getReferenceName)
                .orElse("INVALID");
            var typePart = Optional.ofNullable(reference.getCharacteristicType())
                .map(CharacteristicType::getName)
                .orElse("*");
            var literalPart = Optional.ofNullable(reference.getLiteral())
                .map(Literal::getName)
                .orElse("*");
            return String.format("%s.%s.%s", namePart, typePart, literalPart);
        }
        return super.getText(object);
    }

}
