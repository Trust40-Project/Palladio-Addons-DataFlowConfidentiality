package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl.devided;

import java.util.Stack;

import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.repository.OperationalDataStoreComponent;
import org.palladiosimulator.dataflow.diagram.DataFlowDiagram.Node;
import org.palladiosimulator.dataflow.diagram.characterized.DataFlowDiagramCharacterized.CharacterizedActorProcess;
import org.palladiosimulator.dataflow.diagram.characterized.DataFlowDiagramCharacterized.CharacterizedDataFlow;
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
    
    CharacterizedProcess getProcess(DataChannel dc, Stack<AssemblyContext> context);
    
    CharacterizedStore getStore(OperationalDataStoreComponent component, Stack<AssemblyContext> context);
    
    Pin getOutputPin(CharacterizedProcess process, DataSourceRole sourceRole);
    Pin getOutputPin(CharacterizedProcess process, String pinName);
    
    Pin getInputPin(CharacterizedProcess process, DataSinkRole sourceRole);
    Pin getInputPin(CharacterizedProcess process, String pinName);
    
    Pin getOutputPin(CharacterizedStore store);
    Pin getInputPin(CharacterizedStore store);
    
    CharacterizedDataFlow getDataFlow(Node source, Pin sourcePin, Node destination, Pin destinationPin);
    
}
