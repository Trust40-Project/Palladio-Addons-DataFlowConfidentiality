package org.palladiosimulator.dataflow.confidentiality.pcm.model.editor.conversion;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Map;

import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.CharacterizedActionsPackage;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.expressions.ExpressionsPackage;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.DataDictionaryCharacterizedPackage;
import org.palladiosimulator.pcm.usagemodel.UsagemodelPackage;

public class UsageModelResourceConverter extends ResourceConverterBase {

    public UsageModelResourceConverter() {
        super(UsagemodelPackage.Literals.USAGE_MODEL, createXmlNsEntries(), createTypeReplacements());
    }

    private static Collection<TypeReplacement> createTypeReplacements() {
        String sbFeature = UsagemodelPackage.Literals.USAGE_SCENARIO__SCENARIO_BEHAVIOUR_USAGE_SCENARIO.getName();
        String csb = getXsiType(CharacterizedActionsPackage.Literals.CHARACTERIZABLE_SCENARIO_BEHAVIOR);
        String elscFeature = UsagemodelPackage.Literals.SCENARIO_BEHAVIOUR__ACTIONS_SCENARIO_BEHAVIOUR.getName();
        String elsc = getXsiType(UsagemodelPackage.Literals.ENTRY_LEVEL_SYSTEM_CALL);
        String celsc = getXsiType(CharacterizedActionsPackage.Literals.CHARACTERIZED_ENTRY_LEVEL_SYSTEM_CALL);

        Collection<TypeReplacement> replacements = new ArrayList<>();
        replacements.add(new TypeReplacement(sbFeature, "", csb));
        replacements.add(new TypeReplacement(elscFeature, elsc, celsc));
        return replacements;
    }

    private static Map<String, String> createXmlNsEntries() {
        return createXmlNsEntries(CharacterizedActionsPackage.eINSTANCE, DataDictionaryCharacterizedPackage.eINSTANCE,
                ExpressionsPackage.eINSTANCE,
                org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.expressions.ExpressionsPackage.eINSTANCE);
    }

}
