package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl.devided;

import java.util.Stack;

import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.repository.OperationalDataStoreComponent;
import org.palladiosimulator.dataflow.diagram.characterized.DataFlowDiagramCharacterized.CharacterizedActorProcess;
import org.palladiosimulator.dataflow.diagram.characterized.DataFlowDiagramCharacterized.CharacterizedDataFlow;
import org.palladiosimulator.dataflow.diagram.characterized.DataFlowDiagramCharacterized.CharacterizedNode;
import org.palladiosimulator.dataflow.diagram.characterized.DataFlowDiagramCharacterized.CharacterizedProcess;
import org.palladiosimulator.dataflow.diagram.characterized.DataFlowDiagramCharacterized.CharacterizedStore;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.Pin;
import org.palladiosimulator.indirections.repository.DataChannel;
import org.palladiosimulator.indirections.repository.DataSinkRole;
import org.palladiosimulator.indirections.repository.DataSourceRole;
import org.palladiosimulator.pcm.core.composition.AssemblyContext;
import org.palladiosimulator.pcm.seff.AbstractAction;
import org.palladiosimulator.pcm.seff.ServiceEffectSpecification;
import org.palladiosimulator.pcm.usagemodel.AbstractUserAction;

public interface TransformationResultGetter {

    CharacterizedActorProcess getExitProcess(AbstractUserAction action);
    
    CharacterizedActorProcess getEntryProcess(AbstractUserAction action);
    
    CharacterizedProcess getExitProcess(AbstractAction action, Stack<AssemblyContext> context);
    
    CharacterizedProcess getEntryProcess(AbstractAction action, Stack<AssemblyContext> context);
    
    CharacterizedProcess getProcess(AbstractAction action, Stack<AssemblyContext> context);
    
    CharacterizedProcess getExitProcess(ServiceEffectSpecification seff, Stack<AssemblyContext> context);
    
    CharacterizedProcess getEntryProcess(ServiceEffectSpecification seff, Stack<AssemblyContext> context);
    
    CharacterizedNode getProcess(DataChannel dc, Stack<AssemblyContext> context);
    
    CharacterizedStore getStore(OperationalDataStoreComponent component, Stack<AssemblyContext> context);
    CharacterizedStore getStore(DataChannel dc, Stack<AssemblyContext> context);
    
    Pin getOutputPin(CharacterizedNode process, DataSourceRole sourceRole);
    Pin getOutputPin(CharacterizedNode process, String pinName);
    
    Pin getInputPin(CharacterizedNode process, DataSinkRole sourceRole);
    Pin getInputPin(CharacterizedNode process, String pinName);
    
    Pin getOutputPin(CharacterizedStore store);
    Pin getInputPin(CharacterizedStore store);
    
    CharacterizedDataFlow getDataFlow(CharacterizedNode source, Pin sourcePin, CharacterizedNode destination, Pin destinationPin);
    
}
