package org.palladiosimulator.dataflow.confidentiality.pcm.workflow;

import java.util.Collection;
import java.util.Stack;
import java.util.function.Predicate;

import org.eclipse.emf.ecore.EObject;
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.PCMTraceElement;
import org.palladiosimulator.dataflow.diagram.DataFlowDiagram.DataFlowDiagram;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.CharacteristicType;

import de.uka.ipd.sdq.identifier.Identifier;

public interface TransitiveTransformationTrace {

    Collection<String> getFactIds(EObject pcmElement);
    Collection<String> getFactIds(EObject pcmElement, Stack<Identifier> pcmElementContext);
    Collection<String> getFactId(Predicate<CharacteristicType> predicate);
    Collection<String> getLiteralFactIds(EObject pcmElement);
    Collection<PCMTraceElement> getPCMEntries(String factId);
    
    DataFlowDiagram getDfd();
    
}
