package BSONCommon;

use strict;
use warnings;


sub buildBSONObject(@) {
	my ($exprLocation, $cppExpr, $splType, $seq) = @_;

	if(SPL::CodeGen::Type::isPrimitive($splType)) {
		my $value = handlePrimitive($exprLocation, $cppExpr, $splType);
		return ('append', $value);
	}
	if(SPL::CodeGen::Type::isList($splType) || SPL::CodeGen::Type::isBList($splType) ||
	   SPL::CodeGen::Type::isSet($splType) || SPL::CodeGen::Type::isBSet($splType)) {
		buildBSONObjectFromListOrSet($exprLocation, $cppExpr, $splType, $seq);
		return ('appendArray', "b$seq.arr()");
	}
	elsif(SPL::CodeGen::Type::isMap($splType) || SPL::CodeGen::Type::isBMap($splType)) {
		buildBSONObjectFromMap($exprLocation, $cppExpr, $splType, $seq);
		return ('append', "b$seq.obj()");
	}
	elsif(SPL::CodeGen::Type::isTuple($splType)) {
		buildBSONObjectFromTuple($exprLocation, $cppExpr, $splType, $seq);
		return ('append', "b$seq.obj()");
	}
	else {
		SPL::CodeGen::errorln("Unsupported type %s.", $splType, $exprLocation);
	}
}


sub buildBSONObjectWithKey(@) {
	my ($exprLocation, $attrName, $cppExpr, $splType) = @_;
	my $seq = 0;
	
	if ($attrName) {
		$seq++;
	
print qq(
	BSONObjBuilder b0;
);
	
	}
		
	my ($appendFunction, $value) = BSONCommon::buildBSONObject($exprLocation, $cppExpr, $splType, $seq);
	
	if ($attrName) {

print qq(
	b0.$appendFunction($attrName, $value);
);
	
	}
}


sub buildBSONObjectFromListOrSet(@) {
	my ($exprLocation, $cppExpr, $splType, $seq) = @_;
	my $valueType = SPL::CodeGen::Type::getElementType($splType);
	my $nextSeq = $seq+1;
	
print qq(
	BSONArrayBuilder b$seq;
	typedef STREAMS_BOOST_TYPEOF(($cppExpr)) cppExpr$seq;
	const cppExpr$seq values$seq = $cppExpr;
	foreach (const cppExpr$seq\::value_type & value$seq, values$seq) {
);

	my ($appendFunction, $value) = buildBSONObject($exprLocation, "value$seq", $valueType, $nextSeq);

print qq(
	b$seq.append($value);
	}
);
}


sub buildBSONObjectFromMap(@) {
	my ($exprLocation, $cppExpr, $splType, $seq) = @_;
	my $valueType = SPL::CodeGen::Type::getValueType($splType);
	my $nextSeq = $seq+1;
	
	if(!SPL::CodeGen::Type::isString(SPL::CodeGen::Type::getKeyType($splType))) {
		SPL::CodeGen::errorln("The map key type %s must be of string type.", SPL::CodeGen::Type::getKeyType($splType), $exprLocation);
	}

print qq(
	BSONObjBuilder b$seq;
	typedef STREAMS_BOOST_TYPEOF(($cppExpr)) cppExpr$seq; 
	const cppExpr$seq values$seq = $cppExpr;
	foreach (const cppExpr$seq\::value_type & value$seq, values$seq) {
);

	my ($appendFunction, $value) = buildBSONObject($exprLocation, "value$seq.second", $valueType, $nextSeq);

print qq(
	b$seq.$appendFunction(value$seq.first, $value);
	}
);
}


sub buildBSONObjectFromTuple(@) {
	my ($exprLocation, $cppExpr, $splType, $seq) = @_;
	my @attrNames = SPL::CodeGen::Type::getAttributeNames($splType);
	my @attrTypes = SPL::CodeGen::Type::getAttributeTypes($splType);
	my $nextSeq = $seq+1;
	
print qq(
	BSONObjBuilder b$seq;
	typedef STREAMS_BOOST_TYPEOF(($cppExpr)) cppExpr$seq; 
	const cppExpr$seq tupleData$seq = $cppExpr; 
);

	for (my $i = 0; $i < @attrNames; $i++) {
print qq(
	{
);

		my ($appendFunction, $value) = buildBSONObject($exprLocation, "tupleData$seq.get_$attrNames[$i]()", $attrTypes[$i], $nextSeq);

print qq(
	b$seq.$appendFunction("$attrNames[$i]", $value);
	}
);
	}
	
}


sub handlePrimitive(@) {
	my ($exprLocation, $value, $valueType) = @_;
	
	if(SPL::CodeGen::Type::isComplex($valueType)) {
		SPL::CodeGen::errorln("The complex type is not supported.", $exprLocation);
	}
	elsif(SPL::CodeGen::Type::isBlob($valueType)) {
		return "BSONBinData($value.getData(), $value.getSize(), BinDataGeneral)";
	}
	elsif(SPL::CodeGen::Type::isDecimal($valueType)) {
		SPL::CodeGen::warnln("The decimal type will be converted to float64.", $exprLocation);
		return "spl_cast<float64,$valueType>::cast($value)";
	}
	elsif(SPL::CodeGen::Type::isEnum($valueType)) {
		return "$value.getValue()";
	}
	elsif(SPL::CodeGen::Type::isInt64($valueType) || SPL::CodeGen::Type::isUint64($valueType)) {
		return "static_cast<long long>($value)";
	}
	elsif(SPL::CodeGen::Type::isTimestamp($valueType)) {
		return "Date_t(static_cast<long long>($value.getSeconds() * 1000 + $value.getNanoseconds() / 1000000))";
	}
	elsif(SPL::CodeGen::Type::isUString($valueType)) {
		return "spl_cast<rstring,ustring>::cast($value)";
	}
	elsif(SPL::CodeGen::Type::isXml($valueType)) {
		return "spl_cast<rstring,xml>::cast($value)";
	}
	else {
		return $value;
	}
}


sub keyLess($) {
	my ($splType) = @_;
	return not (SPL::CodeGen::Type::isBMap($splType) || SPL::CodeGen::Type::isMap($splType) || SPL::CodeGen::Type::isTuple($splType));
}

1;
