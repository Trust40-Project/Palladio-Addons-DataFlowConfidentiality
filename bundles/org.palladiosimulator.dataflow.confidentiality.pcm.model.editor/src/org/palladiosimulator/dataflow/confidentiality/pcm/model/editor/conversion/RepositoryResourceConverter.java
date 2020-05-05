package org.palladiosimulator.dataflow.confidentiality.pcm.model.editor.conversion;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Map;

import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.CharacterizedActionsPackage;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.characteristics.CharacteristicsPackage;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.expressions.ExpressionsPackage;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.repository.RepositoryPackage;
import org.palladiosimulator.pcm.core.composition.CompositionPackage;
import org.palladiosimulator.pcm.seff.SeffPackage;

public class RepositoryResourceConverter extends ResourceConverterBase {

    public RepositoryResourceConverter() {
        super(org.palladiosimulator.pcm.repository.RepositoryPackage.Literals.REPOSITORY, createXmlNsEntries(),
                createTypeReplacements());
    }

    private static Collection<TypeReplacement> createTypeReplacements() {
        String ecaFeature = SeffPackage.Literals.RESOURCE_DEMANDING_BEHAVIOUR__STEPS_BEHAVIOUR.getName();
        String eca = getXsiType(SeffPackage.Literals.EXTERNAL_CALL_ACTION);
        String ceca = getXsiType(CharacterizedActionsPackage.Literals.CHARACTERIZED_EXTERNAL_CALL_ACTION);
        String rdseffFeature = org.palladiosimulator.pcm.repository.RepositoryPackage.Literals.BASIC_COMPONENT__SERVICE_EFFECT_SPECIFICATIONS_BASIC_COMPONENT
            .getName();
        String rdseff = getXsiType(SeffPackage.Literals.RESOURCE_DEMANDING_SEFF);
        String crdseff = getXsiType(CharacterizedActionsPackage.Literals.CHARACTERIZED_RESOURCE_DEMANDING_SEFF);
        String assemblyFeature = CompositionPackage.Literals.COMPOSED_STRUCTURE__ASSEMBLY_CONTEXTS_COMPOSED_STRUCTURE
            .getName();
        String cassembly = getXsiType(CharacterizedActionsPackage.Literals.CHARACTERIZABLE_ASSEMBLY_CONTEXT);

        Collection<TypeReplacement> replacements = new ArrayList<>();
        replacements.add(new TypeReplacement(ecaFeature, eca, ceca));
        replacements.add(new TypeReplacement(rdseffFeature, rdseff, crdseff));
        replacements.add(new TypeReplacement(assemblyFeature, "", cassembly));
        return replacements;
    }

    private static Map<String, String> createXmlNsEntries() {
        return createXmlNsEntries(CharacteristicsPackage.eINSTANCE, CharacterizedActionsPackage.eINSTANCE,
                ExpressionsPackage.eINSTANCE,
                org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.expressions.ExpressionsPackage.eINSTANCE,
                RepositoryPackage.eINSTANCE);
    }

}
