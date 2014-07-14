package InsertCommon;

use strict;
use warnings;

sub buildBSONObject(@) {
	my ($model, $exprLocation, $cppExpr, $splType, $seq) = @_;

	if(SPL::CodeGen::Type::isList($splType) || SPL::CodeGen::Type::isBList($splType) ||
	   SPL::CodeGen::Type::isSet($splType) || SPL::CodeGen::Type::isBSet($splType)) {
		buildBSONObjectFromListOrSet($model, $exprLocation, $cppExpr, $splType, $seq);
		return ('appendArray','arr');
	}
	elsif(SPL::CodeGen::Type::isMap($splType) || SPL::CodeGen::Type::isBMap($splType)) {
		buildBSONObjectFromMap($model, $exprLocation, $cppExpr, $splType, $seq);
		return ('append','obj');
	}
	elsif(SPL::CodeGen::Type::isTuple($splType)) {
		buildBSONObjectFromTuple($model, $exprLocation, $cppExpr, $splType, $seq);
		return ('append','obj');
	}
	else {
		SPL::CodeGen::errorln("Unsupported type %s.", $splType, $exprLocation);
	}
}

sub buildBSONObjectFromListOrSet(@) {
	my ($model, $exprLocation, $cppExpr, $splType, $seq) = @_;
	
	print "\n"; print "\t" x $seq; print "BSONArrayBuilder b$seq; \n";
	my $valueType = SPL::CodeGen::Type::getElementType($splType);
	print "\t" x $seq; print "typedef STREAMS_BOOST_TYPEOF(($cppExpr)) cppExpr$seq; \n"; 
	print "\t" x $seq; print "const cppExpr$seq listData$seq = $cppExpr; \n"; 
	print "\t" x $seq; print "for (cppExpr$seq"."::const_iterator it$seq = listData$seq.begin(); it$seq != listData$seq.end(); ++it$seq) { \n";
	if(SPL::CodeGen::Type::isPrimitive($valueType)) {
		my $value = handlePrimitive($exprLocation, "*it$seq", $valueType);
		print "\t" x $seq; print "\t b$seq.append($value); \n";
	}
	else {
		my ($appendFunction,$objFunction) = buildBSONObject($model, $exprLocation, "*it$seq", $valueType, $seq+1);
		print "\t" x $seq; print "\t b$seq.append(b".($seq+1).".$objFunction()); \n";
	}
	print "\t" x $seq; print "} \n";
}

sub buildBSONObjectFromMap(@) {
	my ($model, $exprLocation, $cppExpr, $splType, $seq) = @_;
	
	if(!SPL::CodeGen::Type::isString(SPL::CodeGen::Type::getKeyType($splType))) {
		SPL::CodeGen::errorln("The map key type %s must be of string type.", SPL::CodeGen::Type::getKeyType($splType), $exprLocation);
	}

	print "\n"; print "\t" x $seq; print "BSONObjBuilder b$seq; \n";
	my $valueType = SPL::CodeGen::Type::getValueType($splType);
	print "\t" x $seq; print "typedef STREAMS_BOOST_TYPEOF(($cppExpr)) cppExpr$seq; \n"; 
	print "\t" x $seq; print "const cppExpr$seq mapData$seq = $cppExpr; \n"; 
	print "\t" x $seq; print "for (cppExpr$seq"."::const_iterator it$seq = mapData$seq.begin(); it$seq != mapData$seq.end(); ++it$seq) { \n";
	if(SPL::CodeGen::Type::isPrimitive($valueType)) {
		my $value = handlePrimitive($exprLocation, "it$seq->second", $valueType);
		print "\t" x $seq; print "\t b$seq.append(it$seq->first, $value); \n";
	}
	else {
		my ($appendFunction,$objFunction) = buildBSONObject($model, $exprLocation, "it$seq->second", $valueType, $seq+1);
		print "\t" x $seq; print "b$seq.$appendFunction(it$seq->first, b".($seq+1).".$objFunction()); \n";
	}
	print "\t" x $seq; print "} \n";
}

sub buildBSONObjectFromTuple(@) {
	my ($model, $exprLocation, $cppExpr, $splType, $seq) = @_;

	my @attrNames = SPL::CodeGen::Type::getAttributeNames($splType);
	my @attrTypes = SPL::CodeGen::Type::getAttributeTypes($splType);
	
	print "\n"; print "\t" x $seq; print "BSONObjBuilder b$seq; \n";
	print "\t" x $seq; print "typedef STREAMS_BOOST_TYPEOF(($cppExpr)) cppExpr$seq; \n"; 
	print "\t" x $seq; print "const cppExpr$seq tupleData$seq = $cppExpr; \n"; 
	for (my $i = 0; $i < @attrNames; $i++) {
		print "\t" x $seq; print "{ \n"; 
		if(SPL::CodeGen::Type::isPrimitive($attrTypes[$i])) {
			my $value = handlePrimitive($exprLocation, "tupleData$seq.get_$attrNames[$i]()", $attrTypes[$i]);
			print "\t" x $seq; print "\t b$seq.append(\"$attrNames[$i]\", $value); \n";
		}
		else {
			my ($appendFunction,$objFunction) = buildBSONObject($model, $exprLocation, "tupleData$seq.get_$attrNames[$i]()", $attrTypes[$i], $seq+1);
			print "\t" x $seq; print "b$seq.$appendFunction(\"$attrNames[$i]\", b".($seq+1).".$objFunction()); \n";
		}
		print "\t" x $seq; print "} \n"; 
	}
}

sub handlePrimitive(@) {
	my ($exprLocation, $value, $valueType) = @_;
	
	if(SPL::CodeGen::Type::isComplex($valueType)) {
		SPL::CodeGen::errorln("The complex type is not supported.", $exprLocation);
	}
	elsif(SPL::CodeGen::Type::isDecimal($valueType)) {
		SPL::CodeGen::warnln("The decimal type will be converted to float64.", $exprLocation);
		return "spl_cast<float64,$valueType>::cast($value)";
	}
	elsif(SPL::CodeGen::Type::isBlob($valueType)) {
		return "BSONBinData($value.getData(), $value.getSize(), BinDataGeneral)";
	}
	elsif(SPL::CodeGen::Type::isInt64($valueType) || SPL::CodeGen::Type::isUint64($valueType)) {
		return "static_cast<long long>($value)";
	}
	elsif(SPL::CodeGen::Type::isTimestamp($valueType)) {
		return "SPL::Functions::Time::ctime($value)";
	}
	elsif(SPL::CodeGen::Type::isUString($valueType)) {
		return "spl_cast<rstring,ustring>::cast($value)";
	}
	elsif(SPL::CodeGen::Type::isXml($valueType)) {
		return "spl_cast<rstring,xml>::cast($value)";
	}
	else {
		return "$value";
	}
}

sub keyLess($) {
	my ($splType) = @_;
	return (SPL::CodeGen::Type::isPrimitive($splType) ||
			SPL::CodeGen::Type::isBList($splType) ||
			SPL::CodeGen::Type::isList($splType) ||
			SPL::CodeGen::Type::isBSet($splType) ||
			SPL::CodeGen::Type::isSet($splType));
}

1;
