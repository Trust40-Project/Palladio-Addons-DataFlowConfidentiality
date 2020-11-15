package org.palladiosimulator.dataflow.confidentiality.pcm.visualizer;

import static guru.nidi.graphviz.model.Factory.mutGraph;
import static guru.nidi.graphviz.model.Factory.mutNode;

import java.awt.image.BufferedImage;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.palladiosimulator.dataflow.confidentiality.pcm.visualizer.io.DataFlowGraph;
import org.palladiosimulator.dataflow.confidentiality.pcm.visualizer.io.DataFlowNode;
import org.palladiosimulator.dataflow.confidentiality.pcm.visualizer.io.DataFlowNodeElement;
import org.palladiosimulator.dataflow.confidentiality.pcm.visualizer.io.Entity;

import guru.nidi.graphviz.attribute.Font;
import guru.nidi.graphviz.engine.Format;
import guru.nidi.graphviz.engine.Graphviz;
import guru.nidi.graphviz.model.Link;
import guru.nidi.graphviz.model.LinkSource;
import guru.nidi.graphviz.model.MutableGraph;
import guru.nidi.graphviz.model.MutableNode;

public class DataFlowGraphRenderer {

	private final DataFlowGraph dfGraph;

	public DataFlowGraphRenderer(DataFlowGraph dfGraph) {
		this.dfGraph = dfGraph;
	}

	public BufferedImage getImage(int width, int height) {
		MutableGraph g = convertToGraphviz();
		g.graphAttrs().add("ratio", height/(double)width);
		return Graphviz.fromGraph(g).width(width).height(height).render(Format.SVG).toImage();
	}

	protected MutableGraph convertToGraphviz() {
		MutableGraph g = mutGraph("DFD").setDirected(true).nodeAttrs()
				.add(Font.name("serif")).linkAttrs().add("class", "link-class");

		Map<Integer, MutableNode> nodeDictionary = new HashMap<>();
		for (DataFlowNode dfdNode : dfGraph.getNodes()) {
			MutableNode node = getNode(dfdNode.getElement());
			nodeDictionary.put(dfdNode.getId(), node);
		}

		for (DataFlowNode dfdNode : dfGraph.getNodes()) {
			MutableNode node = nodeDictionary.get(dfdNode.getId());
			List<Link> links = dfGraph.getEdges().stream().filter(edge -> edge.getFrom() == dfdNode.getId())
					.map(edge -> edge.getTo()).map(nodeDictionary::get).map(dstNode -> node.linkTo(dstNode))
					.collect(Collectors.toList());

			node.links().addAll(links);
		}

		g.add(nodeDictionary.values().toArray(new LinkSource[nodeDictionary.size()]));

		return g;
	}

	protected MutableNode getNode(DataFlowNodeElement element) {
		return mutNode(getLabel(element.getEntity()));
	}

	protected String getLabel(Entity element) {
		return String.format("%s (%s)", element.getName(), element.getId());
	}

}
